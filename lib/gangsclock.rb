# gangsclock.rb

W, H = 320, 320
X0, Y0 = [W / 2 - 10, H / 2 - 10]
R = 150
N = 24 * 60

::Gang = Struct.new :name, :utc_offset, :country, :n, :avatar

module GangsClock 
  def position radius, t
    angle = 2 * Math::PI * t / N - Math::PI / 2
    x, y = X0 + radius * Math.cos(angle), Y0 + radius * Math.sin(angle)
    [x.to_i, y.to_i]
  end
  
  def move_avatars
    @groups.each do |group|
      group.each do |g|
        if g.n.to_i < 6
          t = Time.new.getgm + g.utc_offset.to_f * 3600
          h, m = t.hour, t.min
          t = h * 60 + m
          x, y = position(R - 25 - 20*g.n.to_i, t)
          g.avatar.move x , y
          g.avatar.show
        else
          g.avatar.hide
        end
      end
    end
  end

  def gangs_clock
    init
    background @color[0]..@color[1]

    24.times do |t|
      x, y = position(R, t * 60)
      para t.to_s, :left => x, :top => y, :weight => 'bold', :stroke => @color[2]
    end

    @gangs.each do |g|
      fill '../imgs/' + g.name.split(' ').first.downcase + '.jpg'
      nostroke
      g.avatar = image(:width => 20, :height => 20){rect(0, 0, 20, 20, 5)}.hide
      g.avatar.hover{@msg.replace mk_msg(g)}
      g.avatar.leave{@msg.text = ''; @board.hide}
      g.avatar.click do
        @board.clear
        @board.append do
          background @color[0]..@color[1], :curve => 15
          image('../imgs/b-' + g.name.split(' ').first.downcase + '.jpg').move 50, 10
          para mk_msg(g), :left => 10, :top => 120, :stroke => @color[2]
        end
        @board.show
      end
    end
    
    pr1 = proc do |i, e|
      color = ask_color('sellect color')
      clear{@color[i] = color; gangs_clock} if color
    end
    
    menu 'Select Color', %w[upper lower character], 0, pr1, crimson do |b, f, i, e|
      b.move 0, i*23
      f.move 0, i*23
      para e, "\n", :stroke => green, :weight => 'bold'
    end
    
    
    flow :left => 90, :top => 120, :width => 200, :height => 100 do
      @msg = para '', :stroke => @color[2]
    end
    @board = stack(:left => 60, :top => 60, :width => 200, :height => 200).hide
    para link('CWoS'){Thread.new{system 'shoes CWoS_v0.5a.shy'}},
      :left => 0, :top => 295, :weight => 'bold'
    style Shoes::Link, :stroke => white, :underline => nil, :weight => 'bold'
    style Shoes::LinkHover, :stroke => orange, :underline => nil, :weight => 'bold', :fill => nil
    
    move_avatars
    every(60){move_avatars}
  end
  
  def mk_msg g
    #strong(g.name, "\n", g.country, "\n", (Time.new.getgm + g.utc_offset.to_f * 3600).to_s[0..-13])
    strong(g.name, "\n", g.country, "\n", (Time.new.getgm + g.utc_offset.to_f * 3600).strftime("%c")[0..-9])
  end
  
  def init
    @gangs = YAML.load_file 'gangsclock.yml'
    @groups = []
    @gangs.collect{|g| g.utc_offset}.uniq.each do |e|
      o = oval(0, 0, 20)
      tmp = @gangs.select{|g| g.utc_offset == e}.sort_by{|g| g.n}
      @groups << (tmp << Gang.new('', tmp[0].utc_offset, '', '-1', o))
      o.click do
        tmp.each{|g| g.n = g.n.next}
        tmp.each do |g|
          g.n = '-1' if g.n == '-2'
          g.n = '0' if g.n.to_i == tmp.size - 1
        end
        move_avatars
      end
      o.hover do
        f = flow :left => tmp[-1].avatar.left, :top => tmp[-1].avatar.top, 
                 :width => 25, :height => 25 do
          oval 0, 0, 25, :fill => rgb(240, 255, 240, 0.5)
          para tmp.size - 1, :stroke => red, :weight => 'bold'
        end
        timer(1){f.remove}
      end
    end
  end
end
