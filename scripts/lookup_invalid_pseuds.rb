#!script/rails runner
#
# bundle exec rails r script/lookup_invalid_pseuds.rb
#
# Use this script to look up pseuds with invalid icon, icon_alt_text, or
# icon_comment text and prepare to email the users those pseuds belong to.

# Valid icon types, from validates_attachment_content_type in pseuds model.
# image/jpg is not actually a valid type, but we're going to fix that
# instead of deleting the icon, so we don't need to email those users.
valid_types = %w[image/gif image/jpeg image/png image/jpg]

pseuds_with_invalid_icons = Pseud.where("icon_file_name IS NOT NULL AND icon_content_type NOT IN (?)", valid_types)
pseuds_with_invalid_text = Pseud.where("CHAR_LENGTH(icon_alt_text) > ? OR CHAR_LENGTH(icon_comment_text) > ?", ArchiveConfig.ICON_ALT_MAX, ArchiveConfig.ICON_COMMENT_MAX)

invalid_pseuds = [pseuds_with_invalid_icons, pseuds_with_invalid_text].flatten.uniq
invalid_pseuds_count = invalid_pseuds.count

# Get list of users to email.
File.open("/tmp/runme.sh", "w") do |f|
  users_with_invalid_pseuds = invalid_pseuds.map(&:user).uniq

  users_with_invalid_pseuds.each do |user|
    next if user.nil?
    subject = "[AO3] Issue with your AO3 pseud icon"
    f.puts "perl scripts/simple_email.pl -t config/email_templates/2022-03-invalid-pseuds -s \"#{subject}\" -e #{user.email} -u #{user.login}\n"
  end
end
