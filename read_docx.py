import zipfile
import xml.etree.ElementTree as ET
import sys

def extract_text_from_docx(docx_path):
    try:
        with zipfile.ZipFile(docx_path, 'r') as zf:
            xml_content = zf.read('word/document.xml')
        
        tree = ET.fromstring(xml_content)
        namespaces = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
        
        texts = []
        for p in tree.findall('.//w:p', namespaces):
            p_text = ''
            for t in p.findall('.//w:t', namespaces):
                if t.text:
                    p_text += t.text
            if p_text:
                texts.append(p_text)
                
        return '\n'.join(texts)
    except Exception as e:
        return f'Error: {str(e)}'

if __name__ == "__main__":
    if len(sys.argv) > 1:
        print(extract_text_from_docx(sys.argv[1]))
    else:
        print("Provide docx path")
