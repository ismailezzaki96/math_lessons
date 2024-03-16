#!/usr/bin/python3
import re

import yaml


# replace text in file
def replace_text_in_file(file_path, old_text, new_text):
    with open(file_path, "r") as file:
        text = file.read()
        text = text.replace(old_text, str(new_text))
        # text = re.sub(old_text, new_text, text)
    with open(file_path, "w") as file:
        file.write(text)


# read yaml from markdown file
def read_yaml_from_markdown_file(file_path):
    with open(file_path, "r") as file:
        lines = file.readlines()
        text = ""
        start = True
        for line in lines:
            if "---" in line and start:
                start = False
                continue
            if "---" in line and not start:
                break
            text += line
    # print(text)
    out = yaml.safe_load(text)
    return out


# read yaml file and return as dictionary
grade = "TCS"
lesson_number = read_yaml_from_markdown_file("cours.md")["number"]
with open(f"{grade}.yml", "r") as file:
    data = yaml.safe_load(file)

lessons = data["lessons"]

replace_text_in_file("jodada.md", "Item1.1", grade)
replace_text_in_file("jodada.md", "Item2.1", lessons[lesson_number]["chapter"])

replace_text_in_file("jodada.md", "Item3.1", lessons[lesson_number]["test"])
replace_text_in_file("jodada.md", "Item4.1", lessons[lesson_number]["duration"])
replace_text_in_file("jodada.md", "Item5.1", lessons[lesson_number]["semester"])

replace_text_in_file("jodada.md", "Item6.1", lessons[lesson_number]["title"])
