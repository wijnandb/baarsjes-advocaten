#!/bin/bash
# Generate PDFs from markdown using Python markdown + Chrome headless
cd "$(dirname "$0")"

for doc in VOORSTEL RAPPORT; do
    echo "Generating ${doc}.pdf..."

    # Convert markdown to HTML
    python3 -c "
import markdown
with open('${doc}.md', 'r') as f:
    md_content = f.read()
html_body = markdown.markdown(md_content, extensions=['tables', 'fenced_code'])
with open('pdf-template.html', 'r') as f:
    template = f.read()
full_html = template.replace('%%CONTENT%%', html_body)
with open('/tmp/${doc}.html', 'w') as f:
    f.write(full_html)
"

    # Render to PDF via Chrome headless
    google-chrome --headless --disable-gpu --no-sandbox \
        --print-to-pdf="${doc}.pdf" \
        --no-pdf-header-footer \
        "/tmp/${doc}.html" 2>/dev/null

    if [ -f "${doc}.pdf" ]; then
        echo "  ✅ ${doc}.pdf created ($(du -h ${doc}.pdf | cut -f1))"
    else
        echo "  ❌ Failed to create ${doc}.pdf"
    fi
done

# Clean up
rm -f /tmp/VOORSTEL.html /tmp/RAPPORT.html
