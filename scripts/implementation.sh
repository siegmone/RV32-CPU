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
        run_step 0 "Synthesis"  myosys  ./impl/frontend/synth.tcl
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
    *)
        echo "Usage: $0 [0-5]"
        echo "  no argument : run all steps"
        echo "  0 : synthesis"
        echo "  1 : floorplan"
        echo "  2 : placement"
        echo "  3 : CTS"
        echo "  4 : route"
        echo "  5 : final"
        exit 1
        ;;
esac
