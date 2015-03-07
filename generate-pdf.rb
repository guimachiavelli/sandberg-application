require 'prawn'

def insert_image(image_file, project_dir)
    image_file = image_file.gsub('img:', '').strip
    image_file = File.join(project_dir, 'images', image_file)
    image(image_file, :fit => [500, 400]) unless File.extname(image_file) == ''
end

def insert_link(line)
    href = line.gsub('url:', '').strip
    text "<link href='#{href}'>#{href}</link>", :inline_format => true
end

def setup_font
    font_families.update('times' => {
        :normal => './fonts/times.ttf'
    })

    font 'times'
    default_leading 2.5
end

def generate_project_pdf(file, project_dir, project)
    filename = File.join('dist', project + '.pdf')
    Prawn::Document.generate(filename) do
        content = File.new(file)

        setup_font

        content.each_line do |line|
            if line.start_with? 'img:'
                insert_image(line, project_dir)
            elsif line.start_with? 'url:'
                insert_link(line)
            elsif line.start_with? '##'
                start_new_page
                font_size(25) { text line }
            elsif line.start_with? '#'
                font_size(60) { text line }
            else
                text line
            end
            #puts project if line.start_with? 'img:'
            #puts 'image' if line.start_with? 'img:'
        end

        #text(parse_md(content)) if File.extname(file) == '.md'
        #start_new_page
    end
end

def generate_pdfs
    projects_dir = './content'
    projects = Dir.entries(projects_dir)

    projects.each do |project|
        next if project[0] == '.'
        project_dir = File.join(projects_dir, project)
        project_file = File.join(project_dir, 'desc.md')
        puts project_file

        generate_project_pdf project_file, project_dir, project
    end
end

generate_pdfs

