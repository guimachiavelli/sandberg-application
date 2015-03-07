require 'prawn'

def insert_image(image_file, project_dir)
    start_new_page
    image_file = image_file.gsub('img:', '').strip
    image_file = File.join(project_dir, 'images', image_file)
    image(image_file, :fit => [525, 400]) unless File.extname(image_file) == ''
    move_down Random.rand(250)
end

def insert_link(line)
    href = line.gsub('url:', '').strip
    formatted_text [{
        :text => href,
        :link => href,
        :styles => [:underline]
    }]
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
    Prawn::Document.generate(filename, :page_size => 'A4') do
        content = File.new(file)

        setup_font

        content.each_line do |line|
            if line.start_with? 'img:'
                insert_image(line, project_dir)
            elsif line.start_with? 'url:'
                insert_link(line)
            elsif line.start_with? '#'
                font_size(50) { text line.gsub('#', '') }
            else
                text line
            end
        end
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
