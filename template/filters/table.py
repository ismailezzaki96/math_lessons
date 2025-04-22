#!/usr/bin/env python3

import panflute as pf


def improve_table(elem, doc):
    """Improve the appearance of tables"""
    if isinstance(elem, pf.Table):
        # Add toprule
        elem.content[0].content.insert(0, pf.RawInline('\\toprule', 'latex'))

        # Add midrule after header
        if len(elem.content) > 1:
            elem.content[1].content.insert(0, pf.RawInline('\\midrule', 'latex'))

        # Add bottomrule
        elem.content[-1].content.append(pf.RawInline('\\bottomrule', 'latex'))

        # Center-align all columns
        elem.align = ['center'] * len(elem.align)

    return elem

def main(doc=None):
    return pf.run_filters([improve_table], doc=doc)

if __name__ == '__main__':
    main()
