# rubocop: disable Metrics/MethodLength, Metrics/MethodLength, Style/SymbolArray, Layout/IndentationConsistency, Layout/CommentIndentation, Layout/LeadingCommentSpace, Lint/RedundantCopDisableDirective, Lint/SymbolConversion, Lint/Void, Lint/MissingCopEnableDirective, Metrics/ClassLength, Style/NegatedIfElseCondition, Style/QuotedSymbols, Lint/UnreachableCode, Metrics/PerceivedComplexity, Style/FetchEnvVar, Lint/DuplicateBranch
require "net/http"
require "uri"
require "json"

class StudentsController < ApplicationController
  before_action :set_student, only: [:show, :edit, :update, :destroy]

  def index
    @students = Student.where(user_id: @current_user)
  end

  def show
  end

  def new
    current_user

#TOKEN SOPHIA
    url = URI('http://cloud02.sophia.com.br:26000/apiSCL/4375/Api/v1/Autenticacao')

    http = Net::HTTP.new(url.host, url.port)
    request = Net::HTTP::Post.new(url)
    request['Content-Type'] = 'application/json'
    request.body = JSON.dump({ "usuario": ENV["API_USER"], "senha": ENV["API_PASSWORD"] })

    response = http.request(request)
    @oldtoken = response.read_body
    @newtoken = JSON.parse(@oldtoken)

#GET ALUNO DO SOPHIA POR EMAIL
    url = URI("http://cloud02.sophia.com.br:26000/apiSCL/4375/Api/v1/Aluno?emailAluno=#{@current_user.email}")

    http = Net::HTTP.new(url.host, url.port)
    request = Net::HTTP::Get.new(url)
    request['Accept'] = 'application/json'
    request['Content-Type'] = 'application/json'
    request['Token'] = @newtoken

    response = http.request(request)
    puts response.read_body
    @answer1 = response.read_body
    @answer2 = JSON.parse(@answer1)
    @student = Student.new

    if @answer2 == []
      redirect_to cancelado_path
    else
      @codigo = @answer2[0]["Codigo"]
      @nome = @answer2[0]["Nome"]
      @email = @answer2[0]["Email"]

      @student.codigo = @codigo
      @student.name = @nome
      @student.email = @email
      @student.id = current_user.id
      @student.user_id = current_user.id
    end

#TOKEN SOPHIA
    url = URI("https://scld.sophia.com.br/4375/api/v1/Autenticacao")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/json"
    request.body = JSON.dump({ "usuario": ENV["API_USER"], "senha": ENV["API_PASSWORD"] })

    response = https.request(request)
    @oldtoken = response.read_body

#GET ALUNO POR MATRÍCULA
    url = URI("https://scld.sophia.com.br/4375/api/v1/alunos/#{@codigo}/matriculas")
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["Accept"] = "application/json"
    request["Content-Type"] = "application/json"
    request['Token'] = @oldtoken

    response = https.request(request)
    puts response.read_body
    @array = response.read_body
    if @array == ""
      cancelado_path

    else
    @array1 = JSON.parse(@array)
    end
    if @array1 == ""
      cancelado_path
    end

    if @array == ""
      cancelado_path
    elsif @array1[0]["matriculasSet"] == []
      redirect_to cancelado_path
    else
      @situacao = @array1[0]["matriculasSet"].last["situacao"]

      if @situacao == "Cancelada" || @situacao == "Terminada"
        redirect_to cancelado_path
      elsif @current_user.sent == nil
        current_user.sent = true
        current_user.save!(validate: false)
        redirect_to edit_student_path(@student)
      elsif @situacao == "Vigente" && current_user.sent == true
        redirect_to student_path(@student)
      else
        redirect_to cancelado_path
      end

      if Student.find_by_id(@student.id).present?
        student_path(@student)
      else
        @student.save!
      end
    end
  end

  def edit
  end

  def create
    @student = Student.new(student_params)
    @student.user = current_user
    current_user.sent = true
    current_user.save!(validate: false)

    @student.save!
    if @student.save
      redirect_to student_path(@student)
    else
      render :new
    end
  end

  def update
    if @student.update(student_params)
      redirect_to @student, notice: 'Student was sucessfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @student.destroy
    redirect_to students_path, notice: 'Student was sucessfully destroyed.'
  end

  private

  def set_student
    @student = Student.find(params[:id])
  end

  def student_params
    params.require(:student).permit(:name, :codigo, :photo)
  end
end
