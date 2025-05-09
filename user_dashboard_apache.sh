﻿#!/bin/bash

output_file="/var/www/html/user_dashboard.html"
timestamp=$(date "+%Y-%m-%d %H:%M:%S")

cat <<EOF > "$output_file"
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Linux User Dashboard</title>
  <style>
    body { font-family: Arial; background: #f4f4f4; padding: 20px; }
    h1 { color: #333; }
    table { width: 100%; border-collapse: collapse; background: #fff; }
    th, td { padding: 12px; border: 1px solid #ddd; text-align: left; }
    th { background-color: #007BFF; color: white; }
    tr:nth-child(even) { background-color: #f9f9f9; }
    .timestamp { margin-top: 10px; font-size: 0.9em; color: #666; }
  </style>
</head>
<body>
  <h1>👤 Linux User Report Dashboard</h1>
  <div class="timestamp">Last Updated: $timestamp</div>
  <table>
    <tr>
      <th>Username</th>
      <th>UID</th>
      <th>Shell</th>
      <th>Home Directory</th>
      <th>Last Login</th>
      <th>Groups</th>
    </tr>
EOF

for username in $(awk -F: '$3 >= 1000 { print $1 }' /etc/passwd); do
  uid=$(id -u "$username")
  shell=$(getent passwd "$username" | cut -d: -f7)
  home=$(getent passwd "$username" | cut -d: -f6)
  last_login=$(lastlog -u "$username" | awk 'NR==2 {print $4, $5, $6, $7}')
  groups=$(id -Gn "$username" | tr ' ' ', ')

  cat <<EOF >> "$output_file"
    <tr>
      <td>$username</td>
      <td>$uid</td>
      <td>$shell</td>
      <td>$home</td>
      <td>$last_login</td>
      <td>$groups</td>
    </tr>
EOF
done

cat <<EOF >> "$output_file"
  </table>
</body>
</html>
EOF

echo " Dashboard http://$(hostname -I | awk '{print $1}')/user_dashboard.html"
