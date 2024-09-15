pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
function _init()
	--ui info
	ui={
		ma_tlx=3,
		ma_tly=3,
		ma_brx=74,
		ma_bry=124,
		col=flr(rnd(15))
	}
	
	lvl=0
	score=0
	
	--tetris info
	init_x=32
	init_y=-42
	
	--speed
	main_spd=1
	tts_x_spd=0
	tts_y_spd=0
	
	nxt_pc=rnd_tts()
end

function _update()
	--reset speed
	tts_x_spd=0
	tts_y_spd=0

	read_constrols(nxt_pc)
	animate_tetris(nxt_pc)
end

function _draw()
	if ui_col!=0 then
		cls(0)
	else
		cls(6)
	end
	
	draw_tetris(nxt_pc)
	draw_ui()
	print(nxt_pc.x)
	print(nxt_pc.b[1].tlx)
end
-->8
--update
function animate_tetris(tts)
	local spd_y=main_spd+tts_y_spd
	local spd_x=tts_x_spd
	
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
	rect(0,0,127,127,ui.col)
	rect(79,3,124,124,ui.col)
	rect(ui.ma_tlx,ui.ma_tly,ui.ma_brx,ui.ma_bry,ui.col)
	rect(82,6,121,44,ui.col)
	
	--hack to hide tetris
	--at the top of screen
	hack_col=0
	if (ui.col==0) hack_col=6
	rect(1,1,126,2,hack_col)
	
	print("level:",82,70,ui.col)
	rect(82,76,121,84,ui.col)
	print(lvl,84,78,7)
	
	print("score:",82,90,ui.col)
	rect(82,96,121,104,ui.col)
	print(score,84,98,7)
end

function draw_tetris(tts)
		for b in all(tts.b) do
		rect(
			b.tlx+tts.x,
			b.tly+tts.y,
			b.brx+tts.x,
			b.bry+tts.y
		)
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
		{h=14,w=14,m={bm[1],bm[2],bm[4],bm[5]}},
		{h=28,w=7,m={bm[1],bm[4],bm[7],bm[10]}},
		{h=14,w=21,m={bm[2],bm[3],bm[4],bm[5]}},
		{h=14,w=21,m={bm[1],bm[2],bm[5],bm[6]}},
		{h=21,w=14,m={bm[1],bm[4],bm[7],bm[8]}},
		{h=21,w=14,m={bm[2],bm[5],bm[7],bm[8]}},
		{h=14,w=21,m={bm[2],bm[4],bm[5],bm[6]}}
	}
	
	return b_types[flr(rnd(6)+1)]
end

function rnd_tts()
	local tts={
		x=init_x,
		y=init_y
	}
	
	local t=rnd_btype()
	
	tts.b={}
	tts.h=t.h
	tts.w=t.w
	
	for b in all(t.m) do
		add(tts.b,build_blk(b))
	end

	return tts
end
-->8
--[[
	local aux=true
	local height={28,28,28,21,21,21,14,14,14,7,7,7}

	for blk in all(tetris.b) do
		if blk.p>=10 and blk.p<=12 then
			if blk.tly+7<124 then
				blk.tlx+=tts_x_spd
				blk.tly+=spd_y
				blk.brx+=tts_x_spd
				blk.bry+=spd_y
			else
				blk.tly=124-height[blk.p]
				blk.bry=blk.tly+6
				aux=false
			end
		else
			if aux==true then
				blk.tlx+=tts_x_spd
				blk.tly+=spd_y
				blk.brx+=tts_x_spd
				blk.bry+=spd_y
			else
				blk.tly=124-height[blk.p]
				blk.bry=blk.tly+6
			end
		end
	end]]
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
