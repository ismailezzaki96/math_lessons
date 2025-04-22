from docx import Document
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Cm, Mm, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
    # Define colors for headings
heading_colors = {
    'Heading 1': RGBColor(0, 0, 255),  # Blue
    'Heading 2': RGBColor(0, 128, 0),  # Green
    'Heading 3': RGBColor(128, 0, 128)  # Purple
}

# Define a function to set RTL direction
def set_rtl(style_element):
    pPr = style_element.get_or_add_pPr()
    bidi = pPr.find(qn('w:bidi'))
    if bidi is None:
        bidi = OxmlElement('w:bidi')
        pPr.append(bidi)
    bidi.set(qn('w:val'), '1')

# Set base font
base_font_name = 'Tajwal'

def set_styles_to_rtl_and_tajwal(input_path, output_path):
    # Load the existing DOCX document
    doc = Document(input_path)

    # Access the "Line Number" character style
    try:
        line_number_style = doc.styles["Line Number"]
    except KeyError:
        # If the "Line Number" style is not found, create it
        from docx.enum.style import WD_STYLE_TYPE

        line_number_style = doc.styles.add_style("Line Number", WD_STYLE_TYPE.CHARACTER)

    # Set the font color to blue
    line_number_style.font.color.rgb = RGBColor(0x00, 0x00, 0xFF)  # Blue color

    # Define A4 dimensions
    A4_WIDTH = Mm(210)  # 210 mm width
    A4_HEIGHT = Mm(297)  # 297 mm height

    # Define minimum margins (e.g., 0.5 cm)
    MIN_MARGIN = Cm(2)  # 0.5 cm margins

    # Apply settings to all sections in the document
    for section in doc.sections:
        # Set page size to A4
        section.page_width = A4_WIDTH
        section.page_height = A4_HEIGHT

        # Set orientation to portrait (optional)
        section.orientation = section.orientation.PORTRAIT

        # # Set margins to minimum
        # section.top_margin = MIN_MARGIN
        # section.bottom_margin = MIN_MARGIN
        # section.left_margin = MIN_MARGIN
        # section.right_margin = MIN_MARGIN

    # Set line numbering and text direction for each section
    for section in doc.sections:
        sectPr = section._sectPr

        # Create or get the line numbering element
        lnNumType = sectPr.find(qn("w:lnNumType"))
        if lnNumType is None:
            lnNumType = OxmlElement("w:lnNumType")
            sectPr.append(lnNumType)

        # Set line numbering properties
        # lnNumType.set(qn('w:countBy'), '1')    # Number every line
        # lnNumType.set(qn('w:start'), '1')      # Start numbering at 1
        lnNumType.set(qn("w:distance"), "500")  # Distance from text (in twips)
        lnNumType.set(qn("w:alignment"), "right")

        textDirection = sectPr.find(qn("w:textDirection"))
        if textDirection is None:
            textDirection = OxmlElement("w:textDirection")
            sectPr.append(textDirection)
        textDirection.set(qn("w:val"), "rlTb")

        # Set the text direction to right-to-left for the section
        # Access or create the header reference
        pgMar = sectPr.find(qn("w:pgMar"))
        if pgMar is None:
            pgMar = OxmlElement("w:pgMar")
            sectPr.append(pgMar)
        # Optionally adjust margins if needed (e.g., swap left and right margins)
        # pgMar.set(qn('w:left'), '1440')   # Left margin in twips
        # pgMar.set(qn('w:right'), '1440')  # Right margin in twips

    # Iterate over all styles in the document
    for style in doc.styles:
        print(f"Customizing style '{style.name}'...")
        # Set font to Tajwal for all styles that have a font property
        if hasattr(style, "font"):
            style.font.name = "Tajwal"

        # if style.type in [WD_STYLE_TYPE.PARAGRAPH, WD_STYLE_TYPE.CHARACTER]:
        #     # Apply font settings
        #     style.font.name = base_font_name
        #     style.font.size = Pt(12)
        #     style.font.color.rgb = RGBColor(0x00, 0x00, 0x00)  # Black color
        #     style.font.bold = False
        #     style.font.italic = False
        #
        #     # Set complex script font for RTL languages
        #     style.font.cs_name = base_font_name
        #
        #     # Set paragraph formatting for paragraph styles
        #     if style.type == WD_STYLE_TYPE.PARAGRAPH:
        #         # Set right-to-left direction
        #         set_rtl(style.element)
        #
        #         # Adjust paragraph formatting
        #         paragraph_format = style.paragraph_format
        #         paragraph_format.space_before = Pt(6)  # Space before paragraph
        #         paragraph_format.space_after = Pt(6)   # Space after paragraph
        #         paragraph_format.line_spacing = 1.5    # Line spacing
        #         paragraph_format.alignment = 3         # Right alignment (for RTL)
        # Set paragraph styles to RTL
        if style.type == WD_STYLE_TYPE.PARAGRAPH:

            paragraph_format = style.paragraph_format
            current_alignment = paragraph_format.alignment

            # Check if the current alignment is not center
            if current_alignment != WD_ALIGN_PARAGRAPH.CENTER:
                # Set alignment to right
                paragraph_format.alignment = WD_ALIGN_PARAGRAPH.LEFT

            pPr = style.element.get_or_add_pPr()
            bidi = pPr.find(qn("w:bidi"))
            if bidi is None:
                bidi = OxmlElement("w:bidi")
                bidi.set(qn("w:val"), "1")
                pPr.append(bidi)
            else:
                bidi.set(qn("w:val"), "1")

            # Set run properties for paragraph style
            rPr = style.element.get_or_add_rPr()
            rFonts = rPr.find(qn("w:rFonts"))
            if rFonts is None:
                rFonts = OxmlElement("w:rFonts")
                rPr.append(rFonts)
            rFonts.set(qn("w:ascii"), "Tajwal")
            rFonts.set(qn("w:hAnsi"), "Tajwal")
            rFonts.set(qn("w:cs"), "Tajwal")

            # # Set colors for headings
            # if style.name in heading_colors:
            #     color = heading_colors[style.name]
            #
            #     rPr.get_or_add_color().set(qn('w:val'), f'{color.r:02x}{color.g:02x}{color.b:02x}')

        # Set character styles (runs) to RTL and Tajwal
        elif style.type == WD_STYLE_TYPE.CHARACTER:
            rPr = style.element.get_or_add_rPr()
            rtl = rPr.find(qn("w:rtl"))
            if rtl is None:
                rtl = OxmlElement("w:rtl")
                rtl.set(qn("w:val"), "1")
                rPr.append(rtl)
            else:
                rtl.set(qn("w:val"), "1")

            # Set font for character style
            rFonts = rPr.find(qn("w:rFonts"))
            if rFonts is None:
                rFonts = OxmlElement("w:rFonts")
                rPr.append(rFonts)
            rFonts.set(qn("w:ascii"), "Tajwal")
            rFonts.set(qn("w:hAnsi"), "Tajwal")
            rFonts.set(qn("w:cs"), "Tajwal")

    # Customize Heading Styles
    print("Customizing heading styles...")
    for i in range(1, 7):
        style_name = f"Heading {i}"
        try:
            heading_style = doc.styles[style_name]
            heading_style.font.name = base_font_name
            heading_style.font.size = Pt(
                12 + (6 - i) * 3
            )  # Larger font for higher-level headings
            heading_style.font.bold = True
            if i == 1:
            # red color for the first headings
                heading_style.font.color.rgb = RGBColor(0xFF, 0x00, 0x00)  # Red color
            elif i == 2:
                heading_style.font.color.rgb = RGBColor(0x00, 0x00, 0xFF)
            elif i == 3:
            # blue color for the third headings
                heading_style.font.color.rgb = RGBColor(0x00, 0xFF, 0x00)
            else:
                heading_style.font.color.rgb = RGBColor(0x00, 0x00, 0x00)
            heading_style.font.cs_name = base_font_name

            # Set paragraph formatting
            heading_format = heading_style.paragraph_format
            heading_format.space_before = Pt(12)
            heading_format.space_after = Pt(6)
            heading_format.line_spacing = 1.15
            heading_format.alignment = 3  # Right alignment (for RTL)

            # Set right-to-left direction
            set_rtl(heading_style.element)
        except KeyError:
            print(f"Style '{style_name}' not found.")
            # If the heading style doesn't exist, continue
            continue
    # Save the modified document
    doc.save(output_path)


# Usage
set_styles_to_rtl_and_tajwal("./pandoc-manuscript.docx", "output.docx")
