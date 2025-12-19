echo "yolo"



function test() {
    #+-------------------------------------------------------------------------+
    # Load utils
    current_dir=$(dirname "${BASH_SOURCE[0]}")
    source "${current_dir}/install_db.sh"

}



main "${@}"
