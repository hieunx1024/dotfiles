#!/bin/bash

TODO_FILE="$HOME/.config/todo.txt"

if [ -f "$TODO_FILE" ]; then
    # Get the first line
    TODO=$(head -n 1 "$TODO_FILE")
    
    if [ -n "$TODO" ]; then
        # Count remaining tasks
        COUNT=$(wc -l < "$TODO_FILE")
        if [ "$COUNT" -gt 1 ]; then
            echo "󱠇 $TODO (+$((COUNT-1)))"
        else
            echo "󱠇 $TODO"
        fi
    fi
fi
