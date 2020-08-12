require_relative "../config/environment.rb"

class Student

    attr_accessor :id, :name, :grade

    def initialize(name, grade, id=nil)
        @id = id
        @name = name
        @grade = grade
    end 

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS students (
                id INTEGER PRIMARY KEY,
                name TEXT,
                grade INTEGER
            )
            SQL
        DB[:conn].execute(sql)
    end 
    
    def self.drop_table
        sql = "DROP TABLE students;"
        DB[:conn].execute(sql)
    end 

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
                INSERT INTO students (name, grade)
                VALUES (?, ?)
            SQL
            DB[:conn].execute(sql, self.name, self.grade)
            self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM students;")[0][0]
        end 
    end 

    def self.create(name, grade)
        student = Student.new(name, grade)
        student.save
        student 
    end 

    def update
        sql = <<-SQL
            UPDATE students
            SET name = ?, grade = ?
            WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.grade, self.id)
    end 

    def self.new_from_db(row)
        student = Student.new(row[1], row[2])
        student.id = row[0]
        student
    end 

    def self.find_by_name(name)
        sql = "SELECT * FROM students WHERE students.name = ? LIMIT 1;"
        DB[:conn].execute(sql, name).map{ |row| self.new_from_db(row)}[0]
    end 

end
