#!/usr/bin/env python

"""
Pandoc filter to process code blocks with class "graphviz" into
graphviz-generated images.
"""

import hashlib
import os
import sys

import panflute as pf
from panflute import Div, Image, Para, RawBlock, RawInline, Str, toJSONFilter


def sha1(x):
    return hashlib.sha1(x.encode(sys.getfilesystemencoding())).hexdigest()


def ggb(elem, doc):
    if type(elem) == Image and elem.url.endswith(".ggb"):
        doc.ignore = True
        # raw block with ggb file and script to load it in a div
        id = sha1(elem.url)
        script = pf.RawInline(
            f"""
            <br/>
            <div class="ggb" id="{id}"></div>
                        <script>
                        var id = "{id}";
params.filename = "{elem.url}";
var applet = new GGBApplet(params, true);
    applet.setHTML5Codebase('GeoGebra/HTML5/5.0/webSimple/');
    applet.inject(id);
                        </script>
<br/>
                        """,
            format="html",
        )

        # <button onclick="___browserSync___.socket.emit('ggb' , {elem.url}) ); ">Edit</button>
        return script
        return pf.Str("Graph")
        return Para(Div(Str(" "), classes=["ggb"], identifier=elem.identifier))


if __name__ == "__main__":
    toJSONFilter(ggb)
