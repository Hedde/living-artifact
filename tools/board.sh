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
          ... on Issue      { number title url state authorAssociation author{login} labels(first:20){nodes{name}} }
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
        author: ( .content.author.login // "unknown" ),
        assoc:  ( .content.authorAssociation // "NONE" ),
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
  _rows | jq -r 'select(.status=="Ready") | "#\(.number)  \(.title)  [author:\(.author) \(.assoc)]  \(if (.labels|length)>0 then "(" + (.labels|join(",")) + ")" else "" end)"'
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

# Diagnose the environment before a tick — the things that actually block us:
# gh present, jq present, authenticated, and the `project` scope (board reachable).
cmd_preflight() {
  local ok=1
  command -v gh >/dev/null 2>&1 && echo "✓ gh present"  || { echo "✗ gh missing"; ok=0; }
  command -v jq >/dev/null 2>&1 && echo "✓ jq present"  || { echo "✗ jq missing"; ok=0; }
  if gh auth status >/dev/null 2>&1; then
    if gh api graphql -f query="query{user(login:\"$OWNER\"){projectV2(number:$PROJECT_NUMBER){id}}}" >/dev/null 2>&1; then
      echo "✓ board reachable (project scope OK)"
    else
      echo "✗ cannot read project #$PROJECT_NUMBER — token likely missing the 'project' scope."
      echo "  fix: gh auth refresh -h github.com -s project"
      ok=0
    fi
  else
    echo "✗ gh not authenticated — run: gh auth login"; ok=0
  fi
  [ "$ok" = 1 ] && echo "preflight: OK" || { echo "preflight: FAILED" >&2; return 1; }
}

# DoR fields for a card, in one place (no ad-hoc GraphQL needed).
cmd_card() {
  local num="$1"
  _items_json | jq -r --argjson n "$num" '
    .data.user.projectV2.items.nodes[]
    | select(.content.__typename=="Issue" and .content.number==$n)
    | "#\(.content.number)  \(.content.title)\n" +
      "  status:   \( [ .fieldValues.nodes[] | select(.field.name=="Status")   | .name ][0] // "—" )\n" +
      "  size:     \( [ .fieldValues.nodes[] | select(.field.name=="Size")     | .name ][0] // "—" )\n" +
      "  priority: \( [ .fieldValues.nodes[] | select(.field.name=="Priority") | .name ][0] // "—" )\n" +
      "  author:   \(.content.author.login // "unknown") (\(.content.authorAssociation // "NONE"))\n" +
      "  labels:   \( [ .content.labels.nodes[].name ] | join(", ") )"'
}

# Set a card's Size estimate (just-in-time refinement) without raw GraphQL.
cmd_size() {
  local num="$1" size="$2" opt
  case "$size" in
    XS) opt="$SIZE_XS" ;; S) opt="$SIZE_S" ;; M) opt="$SIZE_M" ;;
    L) opt="$SIZE_L" ;; XL) opt="$SIZE_XL" ;;
    *) die "size must be XS|S|M|L|XL" ;;
  esac
  local item_id; item_id="$(_item_id_for "$num")"
  [ -n "$item_id" ] || die "issue #$num is not on the board"
  gh api graphql -f query='
    mutation($p:ID!, $i:ID!, $f:ID!, $o:String!){
      updateProjectV2ItemFieldValue(input:{projectId:$p, itemId:$i, fieldId:$f, value:{singleSelectOptionId:$o}}){ projectV2Item{ id } }
    }' -f p="$PROJECT_ID" -f i="$item_id" -f f="$SIZE_FIELD_ID" -f o="$opt" >/dev/null
  echo "set #$num size = $size"
}

# Security gate (ADR-0006): is this card from a trusted author?
# Exit 0 = trusted (safe to work); exit 1 = UNTRUSTED (do not work without human review).
cmd_trusted() {
  local num="$1" row assoc author ok=0 a u
  row="$(_rows | jq -c --argjson n "$num" 'select(.number==$n)' | head -n1)"
  [ -n "$row" ] || die "issue #$num is not on the board"
  assoc="$(jq -r '.assoc'  <<<"$row")"
  author="$(jq -r '.author' <<<"$row")"
  for a in $TRUSTED_ASSOCIATIONS; do if [ "$assoc"  = "$a" ]; then ok=1; fi; done
  for u in $TRUSTED_AUTHORS;      do if [ "$author" = "$u" ]; then ok=1; fi; done
  if [ "$ok" = 1 ]; then
    echo "trusted   (author:$author assoc:$assoc)"
  else
    echo "UNTRUSTED (author:$author assoc:$assoc) — do not work without human review (ADR-0006)"
    return 1
  fi
}

main() {
  local cmd="${1:-}"; shift || true
  case "$cmd" in
    preflight) cmd_preflight ;;
    items)     cmd_items ;;
    ready)     cmd_ready ;;
    card)      cmd_card "$@" ;;
    trusted)   cmd_trusted "$@" ;;
    status)    cmd_status "$@" ;;
    move)      cmd_move "$@" ;;
    size)      cmd_size "$@" ;;
    comment)   cmd_comment "$@" ;;
    label)     cmd_label "$@" ;;
    fetch-ids) cmd_fetch_ids ;;
    *) cat >&2 <<EOF
board.sh — Living Artifact board adapter
  preflight                     check gh/jq/auth/project-scope before a tick
  items                         list all cards
  ready                         list cards in the Ready lane (with author + association)
  card <n>                      show a card's DoR fields (status/size/priority/author/labels)
  trusted <n>                   security gate: is the card from a trusted author? (ADR-0006)
  status <n>                    print a card's lane
  move <n> "<Lane>"             move a card (validated)
  size <n> <XS|S|M|L|XL>        set a card's size estimate
  comment <n> "<text>"          comment on a card
  label add|remove <n> <label>  manage labels
  fetch-ids                     re-print field/option ids
EOF
       exit 1 ;;
  esac
}
main "$@"
