class Project < ActiveRecord::Base
  has_many :releases, :dependent => :destroy
  has_many :initiatives, :order => 'id DESC', :dependent => :destroy
  has_many :iterations, :order => 'start_date ASC', :dependent => :destroy do
    def first
      self[0]
    end
    
    def past
      self.reverse.select { |i| i.past? }
    end

    def future
      self.select { |i| i.future? }
    end

    def previous
      past.first
    end

    def next
      future.first
    end

    def current
      self.detect { |i| i.current? }
    end
  end
  
  has_many :milestones, :order => 'date ASC', :dependent => :destroy do
    def future
      self.select { |m| m.future? }
    end
  
    def recent
      self.reverse.select { |m| m.recent? }
    end
  
    def past
      self.reverse.select { |m| m.past? }
    end
  end

  has_many :stories, :include => [:iteration, :initiative, :project], :dependent => :destroy do
    def backlog
      self.select { |s| s.iteration.nil? }
    end
    
    def not_estimated_and_not_cancelled
      self.select { |s| 
        s.status != Story::Status::Cancelled and
        s.points.nil?
      }
    end
    
    def not_cancelled_and_not_assigned_to_an_iteration
      self.select{ |s| 
        s.status != Story::Status::Cancelled and
        s.iteration.nil?
      }
    end
    
    def uncompleted
      self.select { |s|
        s.status != Story::Status::Complete and
        s.status != Story::Status::Accepted and
        s.status != Story::Status::Cancelled }
    end
    
    def completed
        self.select { |s|
        s.status == Story::Status::Complete or
        s.status == Story::Status::Accepted  }
    end
    
    def points_completed
      self.completed.inject(0) {|total, completed_story| total + completed_story.points.to_f}
    end
    
    def points_not_completed
      self.uncompleted.inject(0) {|total, uncompleted_story| total + uncompleted_story.points.to_f}
    end
     
    def total_points
      self.uncompleted.inject(0) {|total, uncompleted_story| total + uncompleted_story.points.to_f} + self.points_completed
    end
  end
  
  has_many :users, :through => :project_memberships, :order => 'last_name ASC, first_name ASC'
  has_many :project_memberships
  
  has_many :acceptancetests, :include => [{:story => :iteration}], :dependent => :destroy
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => 100
  
  def current_velocity
    return 0 if self.iterations.past.size == 0
    points_completed_for_velocity/self.iterations.past.size
  end
  
  def points_completed_for_velocity
    points_to_subtract = 0
    if self.iterations.current
      points_to_subtract = self.iterations.current.stories.total_points
    end
    self.stories.points_completed - points_to_subtract
  end
  
  def points_not_completed_for_velocity
    points_to_add = 0
    if self.iterations.current
      points_to_add = self.iterations.current.stories.total_points
    end
    self.stories.points_not_completed + points_to_add
  end
  
  def validate
    if self.planned_iterations
      errors.add(:planned_iterations, "must be a positive integer") if self.planned_iterations < 1
    end
  end
end

