#!/usr/bin/env bash
#
# board.sh — the team's only adapter to the Living Artifact GitHub Project board.
# Everything the team reads or writes about WORK STATE goes through here.
#
# Requires: gh (authenticated with the `project` scope) and jq.
#
# Usage:
#   tools/board.sh items                       # all cards: number, status, labels, title
#   tools/board.sh ready                       # only cards in the "Ready" lane
#   tools/board.sh status <issue-number>       # print a card's current lane
#   tools/board.sh move <issue-number> "<Lane>"  # move a card to a lane (validates transitions)
#   tools/board.sh comment <issue-number> "<text>"
#   tools/board.sh label add|remove <issue-number> <label>
#   tools/board.sh fetch-ids                   # re-print field/option ids (after a board rebuild)
#
# Lanes: "Backlog" | "Ready" | "In progress" | "In review" | "Done"

set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=board.env
source "$HERE/board.env"

die() { echo "board.sh: $*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "missing dependency: $1"; }
need gh; need jq

lane_option_id() {
  case "$1" in
    "Backlog")     echo "$STATUS_BACKLOG" ;;
    "Ready")       echo "$STATUS_READY" ;;
    "In progress") echo "$STATUS_IN_PROGRESS" ;;
    "In review")   echo "$STATUS_IN_REVIEW" ;;
    "Done")        echo "$STATUS_DONE" ;;
    *) die "unknown lane: '$1' (use Backlog|Ready|In progress|In review|Done)" ;;
  esac
}

# Allowed transitions the TEAM may perform (the human may do anything).
# See process/workflow.md.
transition_allowed() {
  local from="$1" to="$2"
  case "$from=>$to" in
    "Ready=>In progress")      return 0 ;;
    "In progress=>In review")  return 0 ;;
    "In review=>Done")         return 0 ;;
    "In review=>In progress")  return 0 ;;  # rework
    "Ready=>Backlog")          return 0 ;;  # failed DoR / blocked
    "In progress=>Backlog")    return 0 ;;  # blocked
    *) return 1 ;;
  esac
}

_items_json() {
  gh api graphql -f query='
    query($org:String!, $num:Int!) {
      user(login:$org){ projectV2(number:$num){ items(first:100){ nodes{
        id
        content{
          __typename
          ... on Issue      { number title url state labels(first:20){nodes{name}} }
          ... on PullRequest{ number title url state }
          ... on DraftIssue { title }
        }
        fieldValues(first:30){ nodes{
          ... on ProjectV2ItemFieldSingleSelectValue { name field{ ... on ProjectV2SingleSelectField{ name } } }
        }}
      }}}}
    }' -F org="$OWNER" -F num="$PROJECT_NUMBER"
}

# Normalised rows: {number,title,url,status,labels[]}
_rows() {
  _items_json | jq -c '
    .data.user.projectV2.items.nodes[]
    | select(.content.__typename=="Issue")
    | { number: .content.number,
        title:  .content.title,
        url:    .content.url,
        state:  .content.state,
        labels: [ .content.labels.nodes[].name ],
        status: ( [ .fieldValues.nodes[] | select(.field.name=="Status") | .name ][0] // "—" ),
        itemId: .id }'
}

_item_id_for() {
  local num="$1"
  _rows | jq -r --argjson n "$num" 'select(.number==$n) | .itemId' | head -n1
}

cmd_items() {
  _rows | jq -r '"#\(.number)  [\(.status)]  \(.title)  \(if (.labels|length)>0 then "(" + (.labels|join(",")) + ")" else "" end)"'
}

cmd_ready() {
  _rows | jq -r 'select(.status=="Ready") | "#\(.number)  \(.title)  \(if (.labels|length)>0 then "(" + (.labels|join(",")) + ")" else "" end)"'
}

cmd_status() {
  local num="$1"
  _rows | jq -r --argjson n "$num" 'select(.number==$n) | .status' | head -n1
}

cmd_move() {
  local num="$1" lane="$2"
  local current; current="$(cmd_status "$num")"
  [ -n "$current" ] || die "issue #$num is not on the board"
  if [ "$current" != "$lane" ]; then
    if ! transition_allowed "$current" "$lane"; then
      die "transition '$current' -> '$lane' is not allowed for the team (see process/workflow.md)"
    fi
  fi
  local item_id; item_id="$(_item_id_for "$num")"
  [ -n "$item_id" ] || die "could not find board item for issue #$num"
  local opt; opt="$(lane_option_id "$lane")"
  gh api graphql -f query='
    mutation($proj:ID!, $item:ID!, $field:ID!, $opt:String!) {
      updateProjectV2ItemFieldValue(input:{
        projectId:$proj, itemId:$item, fieldId:$field,
        value:{ singleSelectOptionId:$opt }
      }){ projectV2Item{ id } }
    }' -f proj="$PROJECT_ID" -f item="$item_id" -f field="$STATUS_FIELD_ID" -f opt="$opt" >/dev/null
  echo "moved #$num: $current -> $lane"
}

cmd_comment() {
  local num="$1" body="$2"
  gh issue comment "$num" --repo "$OWNER/$REPO" --body "$body" >/dev/null
  echo "commented on #$num"
}

cmd_label() {
  local action="$1" num="$2" label="$3"
  case "$action" in
    add)    gh issue edit "$num" --repo "$OWNER/$REPO" --add-label "$label" >/dev/null ;;
    remove) gh issue edit "$num" --repo "$OWNER/$REPO" --remove-label "$label" >/dev/null ;;
    *) die "label action must be add|remove" ;;
  esac
  echo "label $action '$label' on #$num"
}

cmd_fetch_ids() {
  gh api graphql -f query='
    query($org:String!, $num:Int!){ user(login:$org){ projectV2(number:$num){
      id title
      fields(first:30){ nodes{
        ... on ProjectV2FieldCommon{ id name dataType }
        ... on ProjectV2SingleSelectField{ id name options{ id name } }
      }}
    }}}' -F org="$OWNER" -F num="$PROJECT_NUMBER"
}

main() {
  local cmd="${1:-}"; shift || true
  case "$cmd" in
    items)     cmd_items ;;
    ready)     cmd_ready ;;
    status)    cmd_status "$@" ;;
    move)      cmd_move "$@" ;;
    comment)   cmd_comment "$@" ;;
    label)     cmd_label "$@" ;;
    fetch-ids) cmd_fetch_ids ;;
    *) cat >&2 <<EOF
board.sh — Living Artifact board adapter
  items                         list all cards
  ready                         list cards in the Ready lane
  status <n>                    print a card's lane
  move <n> "<Lane>"             move a card (validated)
  comment <n> "<text>"          comment on a card
  label add|remove <n> <label>  manage labels
  fetch-ids                     re-print field/option ids
EOF
       exit 1 ;;
  esac
}
main "$@"
