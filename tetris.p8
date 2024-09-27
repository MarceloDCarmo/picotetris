pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
function _init()
	--ui info
	ui={
		ma_tlx=3,
		ma_tly=3,
		ma_brx=74,
		ma_bry=123,
		col=flr(rnd(15)),
		txt_col=7
	}
	
	lvl=0
	score=0
	
	--tetris info
	init_x=32
	init_y=-42
	lst_t=nil
	placed_tts={}
	
	--speed
	main_spd=1
	tts_x_spd=0
	tts_y_spd=0
	
	act_tts=rnd_tts()
	nxt_tts=rnd_tts()
end

function _update()
	--reset speed
	tts_x_spd=0
	tts_y_spd=0

	if act_tts.act==false then
		act_tts=nxt_tts
		nxt_tts=rnd_tts()
	end

	read_constrols(act_tts)
	animate_tetris(act_tts)
end

function _draw()
	if ui.col!=0 then
		cls(0)
	else
		cls(6)
		ui.txt_col=5
	end
	
	for tts in all(placed_tts) do
		draw_tts(tts)
	end
	
	draw_tts(nxt_tts,true)
	draw_tts(act_tts,false)
	draw_ui()
end
-->8
--update
function animate_tetris(tts)
	local spd_y=main_spd+tts_y_spd
	local spd_x=tts_x_spd
	
	if tts.act then
		tts.x+=spd_x
		tts.y+=spd_y
		
		--check for edge collision
		if (tts.x<ui.ma_tlx) then
		 tts.x=ui.ma_tlx+1
		end
		if (tts.x+tts.w>ui.ma_brx) then
			tts.x=ui.ma_brx-tts.w
		end
		if (tts.y+tts.h>ui.ma_bry) then
			tts.y=ui.ma_bry-tts.h
			tts.act=false
			add(placed_tts,act_tts)
		end
	end
end

function read_constrols(tetris)
	if (btn(⬇️)) tts_y_spd+=2
	if (btn(⬆️)) tts_y_spd-=0.5
	if (btnp(➡️))	tts_x_spd+=7
	if (btnp(⬅️))	tts_x_spd-=7
end
-->8
--draw
function draw_ui()
	--outer border
	rect(0,0,127,127,ui.col)
	--side pannel
	rect(76,3,124,123,ui.col)
	--main area
	rect(ui.ma_tlx,ui.ma_tly,ui.ma_brx,ui.ma_bry,ui.col)
	--next tetris area
	rect(79,6,121,46,ui.col)
	
	--hack to hide tetris
	--at the top of screen
	hack_col=0
	if (ui.col==0) hack_col=6
	rect(1,1,126,2,hack_col)
	
	--level
	print("level:",79,70,ui.col)
	rect(79,76,121,84,ui.col)
	print(lvl,81,78,ui.txt_col)
	
	--score
	print("score:",79,90,ui.col)
	rect(79,96,121,104,ui.col)
	print(score,81,98,ui.txt_col)
end

function draw_tts(tts,nxt)
		for b in all(tts.b) do
		if (ui.col==0) tts.o_col=5
		
		local act_x
		local act_y
		
		if nxt then
			act_x=tts.x
			act_y=tts.y
			tts.x=86
			tts.y=12
		end
		
		rect(
			b.tlx+tts.x,
			b.tly+tts.y,
			b.brx+tts.x,
			b.bry+tts.y,
			tts.o_col
		)
		
		rectfill(
			b.tlx+tts.x+1,
			b.tly+tts.y+1,
			b.brx+tts.x-1,
			b.bry+tts.y-1,
			tts.t.c
		)
		
		if nxt then
			tts.x=act_x
			tts.y=act_y
		end
	end
end
-->8
--collision
function blk_hit(b1,b2)
  local w1=7
  local w2=7
  local h1=7
  local h2=7
  
  hit=false
  local xd=abs((b1.x+(w1/2))-(b2.x+(w2/2)))
  local xs=w1*0.5+w2*0.5
  local yd=abs((b1.y+(h1/2))-(b2.y+(h2/2)))
  local ys=h1/2+h2/2
  if xd<xs and 
     yd<ys then 
    hit=true 
  end
  
  return hit
end

function border_collision(tetris)
 local t_left=tetris.x
 local t_top=tetris.y
 local t_right=t_left+tetris.w
 local t_bottom=t_top+tetris.h
 
 local b_left=ui.ma_tlx+2
 local b_top=ui.ma_tly
 local b_right=ui.ma_brx-1
 local b_bottom=ui.ma_bry-1

 if t_left<b_left then
		return true
 elseif	t_right>b_right then
 	return true
 end
 
 if t_bottom>b_bottom then
		tts_y_spd=0
		main_spd=0
	end
end
-->8
--tetris
function build_blk(b)
	return {
		tlx=b.ox,
		tly=b.oy,
		brx=b.ox+6,
		bry=b.oy+6,
		p=b.p
	}
end

function rnd_btype()
	local bm={}
	
	for y=0,21,7 do
		for x=0,14,7 do
			add(bm,{ox=x,oy=y})
		end
	end
	
	for i=1,#bm do
		bm[i].p=i
	end
	
		--[[
	coordinates to blocks
	
	b1 |b2 |b3
	b4 |b5 |b6
	b7 |b8 |b9
	b10|b11|b12
	
	]]--
	
	local b_types={
		{c=8,h=14,w=14,m={bm[1],bm[2],bm[4],bm[5]}},
		{c=9,h=28,w=7,m={bm[1],bm[4],bm[7],bm[10]}},
		{c=10,h=14,w=21,m={bm[2],bm[3],bm[4],bm[5]}},
		{c=11,h=14,w=21,m={bm[1],bm[2],bm[5],bm[6]}},
		{c=12,h=21,w=14,m={bm[1],bm[4],bm[7],bm[8]}},
		{c=13,h=21,w=14,m={bm[2],bm[5],bm[7],bm[8]}},
		{c=14,h=14,w=21,m={bm[2],bm[4],bm[5],bm[6]}}
	}
	
	return b_types[flr(rnd(6)+1)]
end

function rnd_tts()
	local tts={
		x=init_x,
		y=init_y
	}
	
	local t=rnd_btype()
	--prevents tetris same type in sequence
	while t.c==lst_t do
		t=rnd_btype()
	end
	
	tts.b={}
	tts.h=t.h
	tts.w=t.w
	tts.t=t
	tts.o_col=5
	tts.act=true
	
	for b in all(t.m) do
		add(tts.b,build_blk(b))
	end

	lst_t=tts.t.c
	return tts
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
