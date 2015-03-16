require 'prawn'

def insert_image(image_file, project_dir)
    start_new_page
    image_file = image_file.gsub('img:', '').strip
    image_file = File.join(project_dir, 'images', image_file)
    image(image_file, :fit => [525, 400]) unless File.extname(image_file) == ''
    move_down 15
end

def insert_quote(line)
    start_new_page
    quote = line.gsub('quote:', '').strip
    quote.split(' / ').each { |verse| font_size(25) { text verse  } }
    move_down 15
end

def insert_caption(line)
    caption = line.gsub('caption:', '').strip
    draw_text "#{[0x2191].pack('U')} #{caption}", :at => [0,0], :size => 10
end

def insert_footnote(line, position)
    position = position * 15
    footnote = line.gsub('footnote:', '').strip
    text_box footnote, :at => [0, position], :style => :italic, :size => 10
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
        :normal => './fonts/times.ttf',
        :italic => './fonts/times-it.ttf'
    })

    font 'times'
    default_leading 2.5
end

def generate_project_pdf(file, project_dir, project)
    filename = File.join('dist', project + '.pdf')
    Prawn::Document.generate(filename, :page_size => 'A4') do
        content = File.new(file)
        footnote = 5
        setup_font

        content.each_line do |line|
            if line.start_with? 'img:'
                insert_image(line, project_dir)
            elsif line.start_with? 'url:'
                insert_link(line)
            elsif line.start_with? 'quote:'
                insert_quote(line)
            elsif line.start_with? 'footnote:'
                footnote -= 1
                insert_footnote(line, footnote)
            elsif line.start_with? 'caption:'
                insert_caption(line)
            elsif line.start_with? '===='
                start_new_page
            elsif line.start_with? '##'
                font_size(25) { text line.gsub('#', '') }
            elsif line.start_with? '#'
                font_size(50) { text line.gsub('#', '') }
            else
                font_size(15) { text line }
            end
        end
    end
end

def generate_doc_pdf(doc_file, documents_dir, doc)
    filename = File.join('dist', doc.gsub('.md', '') + '.pdf')
    Prawn::Document.generate(filename, :page_size => 'A4') do
        content = File.new(doc_file)
        setup_font

        content.each_line do |line|
            text line
        end
    end
end

def generate_pdfs
    projects_dir = './content/projects'
    documents_dir = './content/docs'
    projects = Dir.entries(projects_dir)
    documents = Dir.entries(documents_dir)

    projects.each do |project|
        next if project[0] == '.'
        project_dir = File.join(projects_dir, project)
        project_file = File.join(project_dir, 'desc.md')
        puts project

        generate_project_pdf project_file, project_dir, project
    end

    documents.each do |doc|
        next if doc[0] == '.' ||  File.extname(doc) != '.md'
        puts doc
        doc_file = File.join(documents_dir, doc)
        generate_doc_pdf(doc_file, documents_dir, doc)
    end
end

generate_pdfs
