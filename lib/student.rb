require_relative "../config/environment.rb"

class Student

  attr_accessor :id, :name, :grade

  def initialize(id = nil, name, grade)
      @id = id
      @name = name
      @grade = grade
  end

  def self.drop_table
    drop = <<-SQL
    drop table if exists  students 
    SQL

    DB[:conn].execute(drop)
  end

  def self.create_table
    properties = <<-SQL
    create table if not exists students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    );
    SQL

    DB[:conn].execute(properties)
  end

  def save
    if self.id
      self.update
    else
      save_data = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?);
      SQL
  
      DB[:conn].execute(save_data, self.name, self.grade)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]  
    end
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
  end

  def self.new_from_db students_data
    id = students_data[0]
    name = students_data[1]
    grade = students_data[2]
    self.new(id, name, grade)
  end

  def self.find_by_name name
    sql = <<-SQL
    SELECT *
    FROM students
    WHERE name = ?;
  SQL

  DB[:conn].execute(sql, name).map do |student|
    self.new_from_db(student)
  end.first
  end

  def update
    updated_data = <<-SQL
    UPDATE students SET
    name = ?,
    grade = ?
    WHERE id = ?;
    SQL

    DB[:conn].execute(updated_data, self.name, self.grade, self.id)
  end
end
