#!/usr/bin/env python

from panflute import Header, run_filter


def increase_header_level(elem, doc):
    if type(elem) == Header:
        if elem.level == 4:
            elem.attributes.update({"data-pos": "4"})


def main(doc=None):
    return run_filter(increase_header_level, doc=doc)


if __name__ == "__main__":
    main()
