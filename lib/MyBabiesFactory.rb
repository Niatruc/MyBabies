require_relative 'MyBabiesMapper.rb'

class MyBabiesFactory
	RB_LOAD_PATH = 'D:\jruby-9.1.12.0\test\Mybabies\test\mapper\\'
	class << self
		def load_mapper_file(f)
			mapper_str = ""
			File.foreach(RB_LOAD_PATH + f) do |line|  
				mapper_str += line
			end
			mapper_str
		end

		def create_mapper(f)
			mm = MyBabiesMapper.new(load_mapper_file(f))

			mm
		end
	end
end