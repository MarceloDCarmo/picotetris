pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
function _init()
	--main area matrix
	ma=init_ma()
	tts=new_tts()

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
	
	timer=15
end

function _update()
end

function _draw()
	if ui.col!=0 then
		cls(0)
	else
		cls(6)
		ui.txt_col=5
	end

	for b in all(tts) do
		set_act(b.r,b.c,false)
	end
	
	read_ctrls(tts)

	if timer>0 then
		timer-=1
	else
		if tts.b+1<=#ma then
			for b in all(tts) do
				b.r+=1
			end
			tts.b+=1
			timer=15
		end
	end
	
	for b in all(tts) do
		set_act(b.r,b.c,true)
	end
	
	for i=1,#ma do
		for j=1,#ma[i] do
			if ma[i][j].a then
				draw_blk(i,j,tts.col)
			end
		end
	end
	
	draw_ui()
end
-->8
--update
function read_ctrls(tts)
	if (btn(⬇️)) then
		timer-=5
	end
	
	if (btnp(➡️) and tts.r+1<=10)	then
		for b in all(tts) do
			b.c+=1
		end
		tts.r+=1
		tts.l+=1
	end
	
	if (btnp(⬅️) and tts.l-1>=1)	then
		for b in all(tts) do
			b.c-=1
		end
		tts.r-=1
		tts.l-=1
	end
end

function set_act(r,c,act)
	ma[r][c].a=act
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

function draw_blk(r,c,col)
	local x=ma[r][c].x
	local y=ma[r][c].y
	
	--rect(x,y,x+6,y+6)
	spr(col,x,y)
end
-->8
--init
function init_ma()
	local ma={}
	local ox=4 --offset x
	local oy=-24 --offset y
	local bs=7 --block side

	for r=0,20 do
		ma[r+1]={}
		for c=0,9 do
			ma[r+1][c+1]={
				x=c*bs+ox,
				y=r*bs+oy,
				a=false
			}
		end
	end
	
	return ma
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
-->8
--tetris matrix
function new_tts()
		--[[
	coordinates to blocks
	
	1,1 | 1,2 | 1,3 | 1,4
	----------------------
	2,1 | 2,2 | 2,3 | 2,4
	----------------------
	3,1 | 3,2 | 3,3 | 3,4
	----------------------
	4,1 | 4,2 | 4,3 | 4,4
	
	]]--
	
	local types={
		--t
		{
			l=4,r=6,t=3,b=4,col=1,
			{r=4,c=4},
			{r=4,c=5},
			{r=4,c=6},
			{r=3,c=5}
		},
		--s
		{
			l=4,r=6,t=3,b=4,col=2,
			{r=4,c=4},
			{r=4,c=5},
			{r=3,c=5},
			{r=3,c=6}
		},
		--i
		{
			l=5,r=5,t=1,b=4,col=3,
			{r=4,c=5},
			{r=3,c=5},
			{r=2,c=5},
			{r=1,c=5}
		},
		--z
		{
			l=4,r=6,t=3,b=4,col=4,
			{r=3,c=4},
			{r=3,c=5},
			{r=4,c=5},
			{r=4,c=6}
		},
		--o
		{
			l=5,r=6,t=3,b=4,col=5,
			{r=4,c=5},
			{r=4,c=6},
			{r=3,c=5},
			{r=3,c=6}
		},
		--l
		{
			l=5,r=6,t=2,b=4,col=6,
			{r=2,c=5},
			{r=3,c=5},
			{r=4,c=5},
			{r=4,c=6}
		},
		--j
		{
			l=5,r=6,t=2,b=4,col=7,
			{r=2,c=6},
			{r=3,c=6},
			{r=4,c=6},
			{r=4,c=5}
		}
	}
	
	return types[flr(rnd(#types)+1)]
end
__gfx__
0000000088888880bbbbbbb0ccccccc0aaaaaaa0eeeeeee044444440666666600000000000000000000000000000000000000000000000000000000000000000
000000008eeeee80b33333b0c11111c0a99999a0e22222e04fffff40655555600000000000000000000000000000000000000000000000000000000000000000
007007008e888e80b3bbb3b0c1ccc1c0a9aaa9a0e2eee2e04f444f40656665600000000000000000000000000000000000000000000000000000000000000000
000770008e808e80b3b0b3b0c1c0c1c0a9a0a9a0e2e0e2e04f404f40656065600000000000000000000000000000000000000000000000000000000000000000
000770008e888e80b3bbb3b0c1ccc1c0a9aaa9a0e2eee2e04f444f40656665600000000000000000000000000000000000000000000000000000000000000000
007007008eeeee80b33333b0c11111c0a99999a0e22222e04fffff40655555600000000000000000000000000000000000000000000000000000000000000000
0000000088888880bbbbbbb0ccccccc0aaaaaaa0eeeeeee044444440666666600000000000000000000000000000000000000000000000000000000000000000
