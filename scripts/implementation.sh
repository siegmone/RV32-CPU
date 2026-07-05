#!/bin/bash
set -e
STEP="$1"
run_step() {
    local num="$1"
    local desc="$2"
    shift 2
    echo "=== Step $num: $desc ==="
    "$@"
    # Pause only when running the full flow
    if [ -z "$STEP" ]; then
        read -p "Press Enter to continue..."
    fi
}
case "$STEP" in
    "")
        run_step 0 "Synthesis"  myosys   ./impl/frontend/synth.tcl
        run_step 1 "Floorplan"  openroad ./impl/backend/1_floorplan.tcl
        run_step 2 "Placement"  openroad ./impl/backend/2_placement.tcl
        run_step 3 "CTS"        openroad ./impl/backend/3_cts.tcl
        run_step 4 "Route"      openroad ./impl/backend/4_route.tcl
        run_step 5 "Final"      openroad ./impl/backend/5_final.tcl
        ;;
    0)
        myosys ./impl/frontend/synth.tcl
        ;;
    1)
        openroad ./impl/backend/1_floorplan.tcl
        ;;
    2)
        openroad ./impl/backend/2_placement.tcl
        ;;
    3)
        openroad ./impl/backend/3_cts.tcl
        ;;
    4)
        openroad ./impl/backend/4_route.tcl
        ;;
    5)
        openroad ./impl/backend/5_final.tcl
        ;;
    check)
        CHECK_ARG="$2"
        if [ -z "$CHECK_ARG" ]; then
            echo "Usage: $0 check <name>"
            echo "  e.g. $0 check placement"
            exit 1
        fi
        CHECK_SCRIPT="./impl/backend/check_${CHECK_ARG}.tcl"
        if [ ! -f "$CHECK_SCRIPT" ]; then
            echo "Error: check script not found: $CHECK_SCRIPT"
            exit 1
        fi
        openroad "$CHECK_SCRIPT"
        ;;
    *)
        echo "Usage: $0 [0-5|check <name>]"
        echo "  no argument   : run all steps"
        echo "  0             : synthesis"
        echo "  1             : floorplan"
        echo "  2             : placement"
        echo "  3             : CTS"
        echo "  4             : route"
        echo "  5             : final"
        echo "  check <name>  : run ./impl/backend/check_<name>.tcl (e.g. check placement)"
        exit 1
        ;;
esac
