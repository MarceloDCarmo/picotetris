pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
function _init()
	ui_col=flr(rnd(15))
	
	b_types=block_types()
	
	lvl=0
	score=0
	main_spd=1
	tts_x_spd=0
	tts_y_spd=0
	
	nxt_pc=build_tetris(b_types[flr(rnd(6)+1)])
end

function _update()
	--reset speed
	tts_x_spd=0
	tts_y_spd=0

	read_constrols()
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
end
-->8
--update
function build_tetris(pc)	
	local blocks={}
	
	for b in all(pc) do
			add(blocks,build_blk(b.x,b.y))
	end 
	
	return blocks
end

function build_blk(tlx,tly)
	return {
		tlx=tlx,
		tly=tly,
		brx=tlx+6,
		bry=tly+6
	}
end

function animate_tetris(tetris)
	local spd_y=main_spd+tts_y_spd
	local spd_x=tts_x_spd
	
	for blk in all(tetris) do
		blk.tlx+=tts_x_spd
		blk.tly+=spd_y
		blk.brx+=tts_x_spd
		blk.bry+=spd_y
	end
end

function read_constrols()
	if (btn(⬇️)) tts_y_spd+=2
	if (btn(⬆️)) tts_y_spd-=0.5
	if (btnp(➡️)) tts_x_spd+=7
	if (btnp(⬅️)) tts_x_spd-=7
end
-->8
--draw
function draw_ui()
	rect(0,0,127,127,ui_col)
	rect(79,3,124,124,ui_col)
	rect(3,3,74,124,ui_col)
	rect(82,6,121,44,ui_col)
	
	--hack to hide tetris
	--at the top of screen
	hack_col=0
	if (ui_col==0) hack_col=6
	rect(1,1,126,2,hack_col)
	
	print("level:",82,70,ui_col)
	rect(82,76,121,84,ui_col)
	print(lvl,84,78,7)
	
	print("score:",82,90,ui_col)
	rect(82,96,121,104,ui_col)
	print(score,84,98,7)
end

function draw_tetris(tetris)
	for blk in all(tetris) do
		rect(blk.tlx,blk.tly,blk.brx,blk.bry)
	end
end
-->8
--utils
function block_types()
	local bm={}
	
	for y=-42,-14,7 do
		for x=25,39,7 do
			add(bm,{x=x, y=y})
		end
	end
	
		--[[
	coordinates to blocks
	
	b1 |b2 |b3
	b4 |b5 |b6
	b7 |b8 |b9
	b10|b11|b12
	
	]]--
	
	local b_types={
		{bm[8],bm[9],bm[11],bm[12]},
		{bm[2],bm[5],bm[8],bm[11]},
		{bm[10],bm[11],bm[8],bm[9]},
		{bm[7],bm[8],bm[11],bm[12]},
		{bm[5],bm[8],bm[11],bm[12]},
		{bm[5],bm[8],bm[11],bm[10]},
		{bm[10],bm[8],bm[11],bm[12]}
	}
	
	return b_types
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
