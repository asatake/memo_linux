PROGNAME=$(basename $0)
VERSION="1.0"
HELP_MSG="'$PROGNAME -h'と指定することでヘルプを見ることができます"

usage() {
    echo "Usage: $PROGNAME env_name"
    echo 
    echo "オプション:"
    echo "  -h, --help"
    echo "      --version"
    echo
    exit 1
}

for OPT in "$@"
do
  case "$OPT" in
    # ヘルプメッセージ
    '-h'|'--help' )
      usage
      exit 1
      ;;
    # バージョンメッセージ
    '--version' )
      echo $VERSION
      exit 1
      ;;
    '--'|'-' )
      # 「-」か「--」だけ打った時
      shift 1
      param+=( "$@" )
      break
      ;;
    -*)
      echo "$PROGNAME: 「$(echo $1 | sed 's/^-*//')」オプションは存在しません。'$PROGNAME -h'で確認してください" 1>&2
      exit 1
      ;;
    *)
      # コマンド引数（オプション以外のパラメータ）
      if [[ ! -z "$1" ]] && [[ ! "$1" =~ ^-+ ]]; then
        param+=( "$1" )
        shift 1
      fi
      ;;
  esac
done

# パラメータがない場合
if [ -z $param ]; then
    echo "$PROGNAME:コマンド 引数がありません。正しい引数を指定してください" 1>&2
    echo $HELP_MSG 1>&2
    exit 1
fi

echo $param

export WORKON_HOME=~/.virtualenvs
source /usr/bin/virtualenvwrapper.sh
wait $!
mkvirtualenv $param
wait $!
workon $param
wait $!
pip install flake8
wait $!
mkdir ./.vscode
{
    echo "// 既定の設定とユーザー設定を上書きするには、このファイル内に設定を挿入します"
    echo "{"
    echo '  "python.linting.pylintEnabled": false,'
    echo '  "python.linting.enabled": false,'
    echo '  "python.linting.flake8Enabled": true,'
    echo '  "python.linting.flake8Path": "/home/asatake/.virtualenvs/'$param'/bin/flake8",'
    echo '  "python.autoComplete.extraPaths": ['
    echo '    "/home/asatake/.virtualenvs/'$param'/lib/'$(ls /home/asatake/.virtualenvs/$param/lib/)'/site-packages"'
    echo '  ]'
    echo '}'
} > ./.vscode/settings.json
exit 0
