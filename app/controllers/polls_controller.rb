

class PollsController < ApplicationController
  include PollsHelper

  load_and_authorize_resource

  has_filters %w{current expired incoming}
  has_orders %w{most_voted newest oldest}, only: [:show, :answer]

  ::Poll::Answer # trigger autoload

  def index
    @polls = @polls.send(@current_filter).includes(:geozones).sort_for_list.page(params[:page])
  end

  def show
    @questions = @poll.questions.for_render.sort_for_list
    @token = poll_voter_token(@poll, current_user)
    @poll_questions_answers = Poll::Question::Answer.where(question: @poll.questions).where.not(description: "").order(:given_order)
    @answers_by_question_id = {}     
    ::Poll::Answer.by_question(@poll.question_ids).by_author(current_user.try(:id)).each do |answer|
      @answers_by_question_id[answer.question_id] = answer.answer
    end    
    @commentable = @poll
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
  end

  def answer    
    @questions = @poll.questions.for_render.sort_for_list
    @token = poll_voter_token(@poll, current_user)
    @poll_questions_answers = Poll::Question::Answer.where(question: @poll.questions).where.not(description: "").order(:given_order)
    @answers_by_question_id = {}     
    @found_error = false
    @answers = []
    @questions.each do |question| 
      if(question.answers.count()==0)
        next
      end        
      answer_id = params['answer_question_' + question.id.to_s]        
      answer = question.answers.find_or_initialize_by(author: current_user)
      if (answer_id)
        answer.answer = Poll::Question::Answer.find_by_id(answer_id.to_i).title
      else 
        answer.answer = nil
        @found_error = true        
      end
      answer.touch if answer.persisted?
      answer.record_voter_participation(@token)        
      question.question_answers.where(question_id: question).each do |question_answer|
        question_answer.set_most_voted
      end
      @answers_by_question_id[answer.question_id] = answer.answer
      @answers.push(answer)
    end
    @commentable = @poll
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)

    unless @found_error
      @answers.each do |answer|       
        answer.save()
      end
      return redirect_to poll_path(@poll), notice: t("flash.actions.save_changes.notice")      
    else
      @poll_questions_answers = Poll::Question::Answer.where(question: @poll.questions).where.not(description: "").order(:given_order)
      render :action => 'show'      
      return true
    end  
  end


=begin
  def answer    
    @questions = @poll.questions.for_render.sort_for_list
    @token = poll_voter_token(@poll, current_user)    
    questions_without_any_answer = []
    question_counter = 0
    questions_answered_counter = 0    
    answers_by_question_id = {}
    
    @questions.each do |question| 
      # test if exists answer to do a choice
      if(question.answers.count()==0)
        next
      end
      if (params['answer_question_' + question.id.to_s].nil?)
        questions_without_any_answer.insert(0, question.id)
        answers_by_question_id[question.id] = nil
      else        
        answer_id = params['answer_question_' + question.id.to_s]
        answers_by_question_id[question.id] = Poll::Question::Answer.find_by_id(answer_id.to_i).title
      end
    end

    session[:answers_by_question_id] = answers_by_question_id
    
    # save answers in case of no errors
    unless (questions_without_any_answer.any?)
      @questions.each do |question| 
        if(question.answers.count()==0)
          next
        end        
        answer_id = params['answer_question_' + question.id.to_s]        
        question_counter += 1
        unless answer_id.nil?
          questions_answered_counter+=1
          answer = question.answers.find_or_initialize_by(author: current_user)
          answer.answer = Poll::Question::Answer.find_by_id(answer_id.to_i).title
          answer.touch if answer.persisted?
          answer.save
          answer.record_voter_participation(@token)        
          question.question_answers.where(question_id: question).each do |question_answer|
            question_answer.set_most_voted
          end             
        end
      end    
      return redirect_to poll_path(@poll), notice: t("flash.actions.save_changes.notice")      
    else
      session[:questions_without_any_answer] = questions_without_any_answer
      return redirect_to poll_path(@poll)
    end
  end
=end

  def stats
    @stats = Poll::Stats.new(@poll).generate
  end

  def results
  end

end
