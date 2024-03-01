#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 -c [component_name] -s [scale] -v [view] -n [count]"
    echo "Options:"
    echo "  -c : Component Name [INGESTOR/JOINER/WRANGLER/VALIDATOR]"
    echo "  -s : Scale [MID/HIGH/LOW]"
    echo "  -v : View [Auction/Bid]"
    echo "  -n : Count [single digit number]"
    exit 1
}

# Function to validate component name
validate_component() {
    local component=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    case $component in
        ingestor|joiner|wrangler|validator) ;;
        *)
            echo "Invalid component name."
            usage ;;
    esac
}

# Function to validate scale
validate_scale() {
    local scale=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    case $scale in
        mid|high|low) ;;
        *)
            echo "Invalid scale."
            usage ;;
    esac
}

# Function to validate view
validate_view() {
    local view=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    case $view in
        auction|bid) ;;
        *)
            echo "Invalid view."
            usage ;;
    esac
}

# Function to validate count
validate_count() {
    if ! [[ $1 =~ ^[0-9]$ ]]; then
        echo "Invalid count. Must be a single digit number."
        usage
    fi
}

# Function to update the configuration file
update_conf_file() {
    local view=$1
    local scale=$2
    local component=$3
    local count=$4

    if [[ $view == "auction" ]]; then
        view="vdopiasample"
    else
        view="vdopiasample-bid"
    fi

    # Construct the configuration line with variable values
    local config_line="$view ; $scale ; $component ; ETL ; vdopia-etl= $count"

    # Append the configuration line to the end of the file
    echo "$config_line" > sig.conf

    # Check if the echo command succeeded
    if [ $? -eq 0 ]; then
        echo "Conf line appended successfully."
    else
        echo "Error: Failed to append conf line."
        exit 1
    fi
}

# Parse command-line options
while getopts "c:s:v:n:" opt; do
    case $opt in
        c)
            component_name=$OPTARG ;;
        s)
            scale=$OPTARG ;;
        v)
            view=$OPTARG ;;
        n)
            count=$OPTARG ;;
        *)
            usage ;;
    esac
done

# Validate inputs
validate_component "$component_name"
validate_scale "$scale"
validate_view "$view"
validate_count "$count"

# Update configuration file
update_conf_file "$view" "$scale" "$component_name" "$count"
echo "Conf file updated successfully."
