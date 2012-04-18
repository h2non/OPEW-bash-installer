
function cfg.parser ()
{
    IFS=$"\n" && ini=( $(<$1) ) # convert to line-array
    ini=( ${ini[*]//;*/} ) # remove comments ‘;’
    ini=( ${ini[*]//\#*/} ) # remove comments ‘#’
    ini=( ${ini[*]/\ =\ /=} ) # remove anything with a space around ‘ = ‘
    ini=( ${ini[*]/#[/\}$'\n'cfg.section.} ) # set section prefix
    ini=( ${ini[*]/%]/ \(} ) # convert text2function (1)
    ini=( ${ini[*]/=/=\( } ) # convert item to array
    ini=( ${ini[*]/%/ \)} ) # close array parenthesis
    ini=( ${ini[*]/%\( \)/\(\) \{} ) # convert text2function (2)
    ini=( ${ini[*]/%\} \)/\}} ) # remove extra parenthesis
    ini=( ${ini[*]/#\ */} ) # remove blank lines
    ini=( ${ini[*]/#\ */} ) # remove blank lines with tabs
    ini[0]=” # remove first element
    ini[${#ini[*]} + 1]=’}’ # add the last brace
    #printf “%s\n” ${ini[*]}
    eval “$(echo “${ini[*]}”)” # eval the result
}
 
function cfg.writer ()
{
    IFS=' '$'\n'
    fun="$(declare -F)"
    fun="${fun//declare -f/}"
    for f in $fun; do
        [ "${f#cfg.section}" == "${f}" ] && continue
        item="$(declare -f ${f})"
        item="${item##*\{}"
        item="${item%\}}"
        item="${item//=*;/}"
        vars="${item//=*/}"
        eval $f
        echo "[${f#cfg.section.}]"
        for var in $vars; do
            echo $var=\"${!var}\"
        done
    done
}
