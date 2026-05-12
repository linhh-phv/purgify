#!/usr/bin/env python3
"""Generate appcast.xml for Sparkle auto-update.
Usage: gen_appcast.py <version> <build> <size> <url> <date> <signature> [output_path]
"""
import sys

version, build, size, url, date, signature = sys.argv[1:7]
output = sys.argv[7] if len(sys.argv) > 7 else "/tmp/appcast.xml"

xml = (
    '<?xml version="1.0" encoding="utf-8"?>\n'
    '<rss version="2.0"'
    ' xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle"'
    ' xmlns:dc="http://purl.org/dc/elements/1.1/">\n'
    "  <channel>\n"
    "    <title>Purgify</title>\n"
    "    <link>https://github.com/linhh-phv/purgify</link>\n"
    "    <description>Purgify release feed</description>\n"
    "    <language>en</language>\n"
    "    <item>\n"
    f"      <title>Version {version}</title>\n"
    f"      <sparkle:releaseNotesLink>https://github.com/linhh-phv/purgify/releases/tag/v{version}</sparkle:releaseNotesLink>\n"
    f"      <pubDate>{date}</pubDate>\n"
    f'      <enclosure url="{url}" sparkle:version="{build}"'
    f' sparkle:shortVersionString="{version}" length="{size}"'
    f' type="application/octet-stream" sparkle:edSignature="{signature}"/>\n'
    "    </item>\n"
    "  </channel>\n"
    "</rss>\n"
)

with open(output, "w") as f:
    f.write(xml)

print(f"appcast.xml written to {output}")
print(xml)
