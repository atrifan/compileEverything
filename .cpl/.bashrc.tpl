#!/bin/bash
if [[ "${1}" != "--force" && "${1}" != "-f" ]]; then
  echo ${0} not executed for @@TITLE@@ unles called with --force
  return 0
fi
echo ${0} executed for @@TITLE@@

function bashscriptpath() {
  local _sp=$1
  local ascript="$0"
  if [[ "${ascript}" == "-bash" ]] ; then ascript="bash" ; fi
  # echo "D: b0 ascript '$ascript'"
  local asp="$(dirname ${ascript})"
  # echo "D: b1 asp '$asp', b1 ascript '$ascript'"
  if [[ "$asp" == "." && "$ascript" != "bash" && "$ascript" != "./.bashrc" ]] ; then asp="${BASH_SOURCE[0]%/*}"
  elif [[ "$asp" == "." && "$ascript" == "./.bashrc" ]] ; then asp=$(pwd)
  else
    if [[ "$ascript" == "bash" ]] ; then
      ascript=${BASH_SOURCE[0]}
      asp="$(dirname $ascript)"
      if [[ "$asp" == "." ]] ; then asp=$(pwd) ; fi
      #echo "D: bb asp '$asp', b1 ascript '$ascript'"
    fi
    #echo "D: b2 asp '$asp', b2 ascript '$ascript'"
    if [[ "${ascript#/}" != "$ascript" ]]; then
      while [[ ! -e "${asp}/.bashrc" && "${asp}" != "${asp%/*}"  ]]; do # */
        asp=${asp%/*}
      done
    elif [[ "${ascript#../}" != "$ascript" ]]; then
      asp=$(pwd)
      while [[ "${ascript#../}" != "$ascript" ]]; do
        asp=${asp%/*}
        ascript=${ascript#../}
      done
    elif [[ "${ascript#*/}" != "$ascript" ]];  then
      if [[ "$asp" == "." ]] ; then asp=$(pwd) ; elif [[ "${asp#/}" == "${asp}" ]]; then asp="$(pwd)/${asp}"; fi
    fi
  fi
  eval $_sp="'$asp'"
}

if [[ "${H}" == "" ]]; then
  bashscriptpath H
fi
export H=${H}
export HOME=${H}
echo "bashrc set local home to '${H}'"
export HB="$H"/bin
export HS="$H"/sbin
export HSU="$HS"/usrcmd
export HU="$H"/usr
export HUL="${HU}"/local
export HULL="${HUL}"/lib
export HULI="${HUL}"/include
export HULB="${HUL}"/bin
export HULA="${HUL}"/apps
export HULS="${HUL}"/libs
alias sc='source $H/.bashrc --force'

export HISTSIZE=3000
export HISTFILE="${H}/.bash_history"
export HISTFILESIZE=2000
export HISTTIMEFORMAT='%Y-%m-%d %H:%M:%S - '
export HISTIGNORE="&:[ ]*:exit:history:h:l"

# first override the $PATH, making sure to use *local* paths:
export PATH="${H}/sbin:${H}/bin:${HULB}:${HUL}/sbin:${HUL}/ssl/bin"
# then add the application paths which don't end up in ${H}/bin
if [[ -e "${HUL}/jdk7" ]] ; then
  export JAVA_HOME="${HUL}/jdk7"
  export PATH="${PATH}":"${JAVA_HOME}/bin"
else
  export JAVA_HOME=""
fi
if [[ -e "${HUL}/apps/ant" ]] ; then 
  export ANT_HOME="${HUL}/apps/ant"
else
  export -n ANT_HOME
  unset ANT_HOME
fi
#export GITOLITE_HTTP_HOME=${H}
export GITOLITE_HOME="${H}/gitolite"
export PATH="${PATH}":"${GITOLITE_HOME}/bin"
export PATH="${PATH}":/sbin:/bin:/usr/sbin:/usr/bin

export -n NGX_PM_CFLAGS
unset NGX_PM_CFLAGS
export -n CC
unset CC
export CC=gcc
export -n LDDLFLAGS
unset LDDLFLAGS
export -n LD_LIBRARY_PATH
unset LD_LIBRARY_PATH
export -n PKG_CONFIG_PATH
unset PKG_CONFIG_PATH
export -n PERL_LIB
unset PERL_LIB
export -n NGX_AUX
unset NGX_AUX

export LD_RUN_PATH="${HULL}:${HUL}/ssl/lib:${HULA}/svn/lib:${HULA}/python/lib:${HULA}/gcc/lib"
if [[ -e "/usr/lib64" ]] ; then export libarch="/usr/lib64" ; fi
if [[ -e "/usr/lib/i386-linux-gnu" ]] ; then export libarch="/usr/lib/i386-linux-gnu" ; fi
if [[ -e "/usr/lib/i686-linux-gnu" ]] ; then export libarch="/usr/lib/i686-linux-gnu" ; fi
if [[ -e "/usr/lib/x86_64-linux-gnu" ]] ; then export libarch="/usr/lib/x86_64-linux-gnu" ; fi
if [[ "${libarch}" != "" ]] ; then export LD_RUN_PATH="${LD_RUN_PATH}:${libarch#/usr}" ; fi
export LDFLAGS="-L${HULL} -L${HUL}/ssl/lib -L${HULA}/python/lib -Wl,-rpath=${LD_RUN_PATH}"
if [[ -e "${HULS}/gettext" ]] ; then export LDFLAGS="-lintl ${LDFLAGS}" ; fi
if [[ -e "${HULL}64/libffi.so" ]] ; then export LDFLAGS="-lintl -lffi -L${HULL}64 ${LDFLAGS}" ; fi
export CFLAGS="-I${HULI} -I${HUL}/ssl/include -fPIC -O -U_FORTIFY_SOURCE @@M64@@ @@CYGWIN@@"
export CPPFLAGS="$CFLAGS"
export PERL5LIB="${HULA}/perl/lib/site_perl/current:${HULA}/perl/lib/current"

export SSL_CERT_FILE="${H}/.ssh/cert.pem"

export LYNX_CFG="${H}/lynx/lynx.cfg"

export CATALINA_HOME="${H}/usr/local/apps/tomcat"
export CATALINA_BASE="${H}/tomcat"

alias a=alias
alias l='ls -alrt'
alias h=history
alias vi=vim
alias t='tail --follow=name'
alias tl='while ! tail --max-unchanged-stats=2 --follow=name "${H}/.lastlog" ; do sleep 2 ; done'
alias psw='ps auxwww|grep "${H}"|grep -v grep|grep'

oag=$(alias git 2>/dev/null| grep "${H}" | grep " u ")
if [[ "${oag}" == "" ]] ; then
  alias git="${H}/sbin/wgit"
fi

if [[ -e "${H}/.bashrc_aliases_git" ]] ; then source "${H}/.bashrc_aliases_git" ]] ; fi

if [[ ! -e "${H}/.ssh/curl-ca-bundle.crt" ]] ; then cp "${H}/.cpl/scripts/curl-ca-bundle.crt" "${H}/.ssh"; fi
if [[ -e "${H}/.ssh/curl-ca-bundle.crt.secret" ]] ; then
  a=$(tail -10 "${H}/.ssh/curl-ca-bundle.crt.secret")
  b=$(tail -10 "${H}/.ssh/curl-ca-bundle.crt")
  if [[ "$a" != "$b" ]] ; then
    cat "${H}/.ssh/curl-ca-bundle.crt.secret" >> "${H}/.ssh/curl-ca-bundle.crt"
  fi
fi

export GIT_SSL_CAINFO="${H}/.ssh/curl-ca-bundle.crt"
if [[ ! -e "${H}/.gitconfig" ]] ; then
  "${H}/sbin/cp_tpl" "${H}/.cpl/.gitconfig.tpl" "${H}"
fi
if [[ ! -e "${H}/.bashrc_aliases_git" ]] ; then cp "$H/.cpl/.bashrc_aliases_git.tpl" "$H/.bashrc_aliases_git" ; fi

export EDITOR=vim

findg() { find . -name '*' |  xargs grep -nHr "$1" ; }

if [[ -e "${H}/.proxy.private" ]] ; then source "${H}/.proxy.private" ; 
elif [[ -e "${H}/../.proxy.private" ]] ; then source "${H}/../.proxy.private" ; fi

alias gr='git update-index --assume-unchanged "${H}/README.md"'

if [[ ! ${ce_key128} ]] ; then
  ce_key128=$(echo "key-$RANDOM-$$-$(date)" | md5sum | md5sum)
  ce_key128=${ce_key128:0:32}
  export ce_key128=${ce_key128}
fi
if [[ ! ${ce_iv} ]] ; then
  ce_iv=$(echo "iv-$RANDOM-$$-$(date)" | md5sum | md5sum)
  ce_iv=${ce_iv:0:32}export LIBRARY_PATH=/usr/lib/i386-linux-gnu
  export ce_iv=${ce_iv}
fi
if [[ ! ${ce_session} ]] ; then
  ce_session=$(echo "session-$RANDOM-$$-$(date)" | md5sum | md5sum)
  ce_session=${ce_session:0:32}
  export ce_session=${ce_session}
  #mkdir -p "${H}/.crypt/${ce_session}"
fi

export SANDBOX_HOME="${H}/mysql/sandboxes"
export SANDBOX_BINARY="${H}/usr/local/apps/mysql"

if [[ -e "${HULA}/pkgconfig" ]] ; then
  export PKG_CONFIG_PATH="${HULL}/pkgconfig:${HUL}/ssl/lib/pkgconfig"
fi
if [[ -e "${HULB}/libtool" ]] ; then
  export LIBTOOL="${HULB}/libtool"
fi

export CMAKE_PREFIX_PATH="${HUL}:${HUL}/ssl"
export CMAKE_LIBRARY_PATH="${HULL}:${HUL}/ssl/lib"
export CMAKE_INCLUDE_PATH="${HULI}:${HUL}/ssl/include"
export CMAKE_SYSTEM_IGNORE_PATH="/lib/i386-linux-gnu:/usr/lib64:/usr/lib:/usr/lib/i386-linux-gnu:/lib/i386-linux-gnu:/usr/lib/x86_64-linux-gnu:/lib/x86_64-linux-gnu"
export CMAKE_IGNORE_PATH="${CMAKE_SYSTEM_IGNORE_PATH}"
export CMAKE_SYSTEM_LIBRARY_PATH="/lib:/usr/lib"
export CMAKE_PROGRAM_PATH="${HB}"

if [[ -e "${H}/sbin/ssh" ]] ; then export GIT_SSH="${H}/sbin/ssh" ; fi

export -n LIBRARY_PATH
export -n C_INCLUDE_PATH
export -n CPLUS_INCLUDE_PATH

# Multi-arch support
if [[ "${libarch}" != "" ]] ; then
  export LIBRARY_PATH="${libarch}"
  if [[ "${libarch}" != "/usr/lib64" ]] ; then
    export C_INCLUDE_PATH="${libarch/lib/include}"
    export CPLUS_INCLUDE_PATH="${libarch/lib/include}"
  fi
fi
	      
alias gpg="${H}/sbin/gpg"
alias gpgs="${H}/sbin/gpg --batch -q"

# http://superuser.com/a/450630/141
export GPG_TTY=$(tty)

if [[ "${MANPATH}" == "" ]] ; then export MANPATH="${HUL}/share/man"; fi
if [[ "${MANPATH#*$H}" == "${MANPATH}" ]] ; then export MANPATH="${HUL}/share/man:${MANPATH}"; fi

if [[ -e "${H}/go/latest/bin/go" ]]; then
  export GOROOT=${H}/go/latest
  export PATH=$PATH:${GOROOT}/bin
  export GOPATH=${H}/go/projects
fi
if [[ ! -e "${H}/.cpl/bash_ld_preload.so" && -e "${H}/.cpl/bash_ld_preload.c" && -e "${HB}/gcc" ]]; then
  gcc "${H}/.cpl/bash_ld_preload.c" -fPIC -shared -Wl,-soname,bash_ld_preload.so.1 -o "${H}/.cpl/bash_ld_preload.so"
fi
if [[ -e "${H}/.cpl/bash_ld_preload.so" ]]; then
  export LD_PRELOAD=${H}/.cpl/bash_ld_preload.so
else
  export -n LD_PRELOAD
  unset LD_PRELOAD
fi
