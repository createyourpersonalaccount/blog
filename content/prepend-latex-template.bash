#!/usr/bin/env bash

for path in "$@"; do
    depth=$(./find-path-length.bash "$path")
    dots=""
    for ((i = 0; i < depth; ++i)); do
        dots="../${dots}"
    done
    awkstr=$(printf '{if ($0 !~ /^#\+/ && !b) {print "#+INCLUDE: %s%s"; print "#+BIBLIOGRAPHY: %s%s"; print "#+CITE_EXPORT: csl %s%s"; print $0; b=1;} else {print $0} }' "$dots" "latex-template.org" "$dots" "bibliography.bib" "$dots" "elsevier-with-titles.csl")
    awk "$awkstr" "$path" > "${path}.tmp"
    mv "${path}.tmp" "$path"
done
