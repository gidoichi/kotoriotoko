#!/bin/sh

######################################################################
#
# 引数で与えられた時刻（YYYYMMDD）より前のツイート及びいいねを取り消す
#
######################################################################


# === このシステム(kotoriotoko)のホームディレクトリー等 ==============
Homedir="$(d=${0%/*}/; [ "_$d" = "_$0/" ] && d='./'; cd "$d.."; pwd)"


# === 一時ファイルのプレフィックス ===================================
Tmp="/tmp/${0##*/}.$(date +%Y%m%d%H%M%S).$$"


# === 引数チェック ===================================================
if ! echo $1 | grep '^[0-9]\{8\}$' >/dev/null; then
  echo Invalid parameter >&2
  exit 1
fi
before=$1


# === ツイートの取り消し =============================================
echo [DELETE TWEETS]
echo unimplemented >&2


# === いいねの取り消し ===============================================
echo [UNFAVORITE]
maxid=""
while :; do
  # 通知
  if [ -z "$maxid" ]; then
    echo search from latest
  else
    echo search before $(cat $Tmp-tweetdateid |
                         tail -n 1            |
                         cut -d ' ' -f 1      |
                         sed 's/_/ /g'        )
  fi

  # 取得可能な範囲のツイート取得
  if [ -z "$maxid" ]; then                      #
    "$Homedir/BIN/favtws.sh"                    #
  else                                          #
    "$Homedir/BIN/favtws.sh" -m $maxid          #
  fi                                            |
  awk '/^[0-9]/{cnt=0}                          #
       {cnt++}                                  #
       cnt==1{gsub(" ", "_"); printf "%s ", $0} #
       cnt==5{print $2}'                        |
  sed 's#https://.*/##'                         |
  grep -v ' '"$maxid"'$'                        > $Tmp-tweetdateid

  # すべての探索が済んだら終了
  if [ -z "$(cat $Tmp-tweetdateid | awk 'NF')" ]; then break; fi

  # 取り消し処理
  cat $Tmp-tweetdateid           |
  sed 's#/##g'                   |
  sed 's/_.* / /'                |
  awk '$1<'"$before"'{print $2}' |
  "$Homedir/BIN/twunfav.sh"      |
  sed 's/^/twunfav.sh: /'

  # 次の探索の準備
  maxid=$(cat $Tmp-tweetdateid | tail -n 1 | cut -d ' ' -f 2)
done


# === 終了 ===========================================================
[ -n "$Tmp" ] && rm -rf "$Tmp"*
exit 0
