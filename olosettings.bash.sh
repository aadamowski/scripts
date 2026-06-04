# Obsluga:
#if [ -f $HOME/bin/olosettings.bash.sh ]; then
#  . $HOME/bin/olosettings.bash.sh
#fi

alias today_date="date +%F"
alias now_time="date +%H_%M_%S"
alias mkdir_curdate='mkdir $(today_date)'
alias mkdir_cd_curdate='mkdir $(today_date); cd $_'
alias cd_curdate='cd $(today_date)'
alias cd_curdate_latest='cd $(ls -d [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] | tail -n 1 )'
alias mkdir_nowtime='mkdir $(now_time)'
alias mkdir_curdate_nowtime='mkdir -p $(today_date)/$(now_time)'
alias mkdir_cd_curdate_time='mkdir -p $(today_date)/$(now_time); cd $_'
alias mkdir_curtimestamp='mkdir $(date +%F_%H_%M_%S)'
alias mkdir_cd_curtimestamp='mkdir $(date +%F_%H_%M_%S); cd $_'


alias dusage_in_curdir='du -xk --max-depth=1 . | sort -n'

alias LOCALE_C='export LANG=C; export LANGUAGE=C; export LC_MESSAGES=C'

alias ololize='chown -R olo:olo .'
alias rootize='chown -R root:root .'

alias vim_latin2='vim --cmd "edit ++enc=latin2 $1"'

