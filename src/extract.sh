#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
failed=0
ask_password() {
    /usr/bin/osascript - "$1" "$2" <<'APPLESCRIPT'
on run argv
    tell application "Finder"
        activate
        try
            set dialogResult to display dialog (item 2 of argv & return & item 1 of argv) with title "unar 解压密码" default answer "" with hidden answer buttons {"取消", "解压"} default button "解压" cancel button "取消"
            return text returned of dialogResult
        on error number -128
            error number -128
        end try
    end tell
end run
APPLESCRIPT
}
show_error() {
    /usr/bin/osascript - "$1" "${2:0:2000}" <<'APPLESCRIPT'
on run argv
    tell application "Finder"
        display dialog ("未能解压：" & item 1 of argv & return & return & item 2 of argv) with title "unar 解压失败" buttons {"好"} default button "好" with icon caution
    end tell
end run
APPLESCRIPT
}
stage=""
cleanup_stage() {
    if [ -n "$stage" ] && [ -d "$stage" ]; then
        /bin/rm -rf -- "$stage"
    fi
    stage=""
}
trap cleanup_stage EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
extract_attempt() {
    cleanup_stage
    stage="$(/usr/bin/mktemp -d "$destination/.unar-extract.XXXXXXXX")" || {
        details="无法在压缩包所在位置创建临时文件夹，请检查写入权限。"
        return 1
    }
    details="$(/opt/homebrew/bin/unar -r -d -o "$stage" "$@" "$archive" </dev/null 2>&1)"
    result=$?
    if [ "$result" -ne 0 ]; then
        cleanup_stage
        return "$result"
    fi
}
publish_result() {
    shopt -s dotglob nullglob
    extracted=("$stage/"*)
    if [ "${#extracted[@]}" -ne 1 ] || [ ! -d "${extracted[0]}" ]; then
        details="解压结果结构异常，未保存到原文件夹。"
        cleanup_stage
        return 1
    fi
    folder_name="${extracted[0]##*/}"
    target="$destination/$folder_name"
    suffix=0
    while ! /bin/mkdir "$target" 2>/dev/null; do
        if [ ! -e "$target" ] && [ ! -L "$target" ]; then
            details="无法创建解压文件夹，请检查写入权限。"
            cleanup_stage
            return 1
        fi
        suffix=$((suffix + 1))
        target="$destination/$folder_name-$suffix"
    done
    if ! /usr/bin/ditto "${extracted[0]}" "$target"; then
        /bin/rm -rf -- "$target"
        details="保存解压结果失败，请检查磁盘空间与写入权限。"
        cleanup_stage
        return 1
    fi
    cleanup_stage
}
for archive in "$@"; do
    [ -f "$archive" ] || continue
    destination="$(/usr/bin/dirname "$archive")"
    listing="$(/opt/homebrew/bin/lsar -j "$archive" </dev/null 2>&1)"
    encrypted=0
    if printf '%s' "$listing" | /usr/bin/grep -Eqi '"XADIsEncrypted"[[:space:]]*:[[:space:]]*true|requires a password|password required|password to (unpack|open)|encrypted (archive|headers)'; then
        encrypted=1
    fi
    unset listing
    if [ "$encrypted" -eq 0 ]; then
        if extract_attempt; then
            if ! publish_result; then
                failed=1
                show_error "$archive" "$details"
            fi
            continue
        fi
        if ! printf '%s' "$details" | /usr/bin/grep -Eqi 'requires a password|password required|password to (unpack|open)|encrypted (archive|headers)'; then
            failed=1
            show_error "$archive" "$details"
            continue
        fi
    fi
    message="请输入压缩包密码（不会保存）："
    for attempt in 1 2 3; do
        if ! password="$(ask_password "$(/usr/bin/basename "$archive")" "$message")"; then
            unset password
            break
        fi
        if extract_attempt -p "$password"; then
            unset password
            if ! publish_result; then
                failed=1
                show_error "$archive" "$details"
            fi
            break
        fi
        unset password
        message="解压未成功，请检查密码后重试（第 $((attempt + 1)) 次，共 3 次）："
        if [ "$attempt" -eq 3 ]; then
            failed=1
            show_error "$archive" "$details"
        fi
    done
done
unset password details
[ "$failed" -eq 0 ]
