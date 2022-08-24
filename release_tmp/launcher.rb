require 'zip'

$files = {}
$requires = []

Zip::File.open('gamedata') do |file|
    file.each do |entry|
        if entry.file?
            content = ""
            entry.get_input_stream { |io| content = io.read }

            if entry.name == "requires.req"
                $requires = content.split("\n")
            else
                $files[entry.name.gsub(".rb", "").downcase] = content
            end
        end
    end
end

i = 0
$requires.each do |fpath|
    fpath_cleaned = fpath.gsub("\r", "").downcase
    eval($files[fpath_cleaned])
end
