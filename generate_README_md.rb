#!/usr/bin/env ruby
#language: Ruby
#filename: generate_README_md.rb
#description: tool to automate the Generation of README.md files.
#date: 12/28/2019
#
def get_list_of_files_in_repositories
  list_of_files=[] #all files besides README.md
  list_of_files=Dir.glob("[!README.md]*") #everthing but README.md
  return list_of_files
end

def open_file_and_return_raw_header(filename)
  header=[]
  my_file=IO.readlines(filename)
  my_file.each do | line |
    header.push(line) if line.match(/^#!/)
    header.push(line) if line.match(/^#lang/)
    header.push(line) if line.match(/^#desc/)
  end

  puts header

  return header
end

def parse_header(header,file)
  lang="unknown"
  desc="unknown"
  header.each do | line |
    if line.match(/lang/i)
        lang=line.split(":")[1].downcase
    elsif line.match(/.*env/i)
        lang=line.split("env ")[1]
    elsif line.match(/^#!\/usr\/bin/i)
        lang=line.split("//")[2]
    end
    if line.match(/^#file/i)
      file=line.split(":")[1]
    end
    if line.match(/^#desc/i)
      desc=line.split(":")[1].chomp.gsub(/^\s*/, "")
    end
 end

  return  { :lang => "#{lang}",
            :file => "#{file}",
            :desc => "#{desc}" }

end

def generate_readme_md(myfilename,my_files)


  fd = IO.sysopen(myfilename, "w")
  a = IO.new(fd,"w")

  a.puts "Most of it is just for fun.\r\n\r\n"
  a.puts "It showcases some of things I can do.\r\n\r\n"

  a.puts "Filename | Description | Language \r\n"
  a.puts "----------- | ----------- | ---------- \r\n"

  my_files.each  do | f_name|
    parsed_header=[]
    raw_header = open_file_and_return_raw_header(f_name)
    parsed_header=parse_header(raw_header,f_name)
    a.puts "#{parsed_header[:file]} | #{parsed_header[:desc]} | #{parsed_header[:lang]}\r\n"
  end
  a.close
end


my_files=[]
my_files=get_list_of_files_in_repositories
generate_readme_md("README.md",my_files)

