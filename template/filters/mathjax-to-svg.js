#!/usr/bin/env node

const pandoc = require("pandoc-filter");
const execSync = require("child_process").execSync;
const path = require("path");
const fs = require("fs");
const { Console } = require("console");
const { Str, Image } = pandoc;

const convertMathToSvg = (math) => {
  // Create a temporary filename for the SVG output
  const svgFilename = `temp_${Date.now()}.svg`;

  // Run MathJax to convert the LaTeX math to SVG
  execSync(`mathjax-node-cli -i "${math}" -o ${svgFilename} --svg`);

  // Read the SVG content
  const svgContent = fs.readFileSync(svgFilename, "utf8");

  // Remove the temporary file
  fs.unlinkSync(svgFilename);

  return svgContent;
};

const action = (type, value, format, meta) => {
  if (type === "Math" ) {
    const math = value[1];  // The actual LaTeX math expression
    Console.log("Math: ", math);

    // Convert to SVG
    const svgContent = convertMathToSvg(math);

    // Embed SVG as an image in the DOCX
    return Image([Str("Math")], [svgContent, ""]);
  }
};

pandoc.stdio(action);
