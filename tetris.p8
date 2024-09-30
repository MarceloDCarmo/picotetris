pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--[[
in order to make the new tetris
work, i need to create new objects
]]
function _init()
	--main area matrix
	ma=init_ma()
	--next tts area
	na=init_na()
	--initi types
	types=init_types()
	--controls when to call next tts
	call_nxt=false
	
	act_tts=new_tts()
	nxt_tts=new_tts()

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
	if call_nxt then
		act_tts=nxt_tts
		nxt_tts=new_tts()
		call_nxt=false
	end

	upd_nxt_tts(nxt_tts)
	upd_act_tts(act_tts)
end

function _draw()
	if ui.col!=0 then
		cls(0)
	else
		cls(6)
		ui.txt_col=5
	end
	
	--draw next tts
	draw_tts(na,nxt_tts)
	
	--draw active tts
	draw_tts(ma,act_tts)	
	draw_ui()
end
-->8
--update
function read_ctrls(tts)
	if (btn(⬇️)) then
		timer-=5
	end
	
	if (btnp(➡️) and tts.r+1<=10)	then
		for b in all(tts.blks) do
			b.c+=1
		end
		tts.r+=1
		tts.l+=1
	end
	
	if (btnp(⬅️) and tts.l-1>=1)	then
		for b in all(tts.blks) do
			b.c-=1
		end
		tts.r-=1
		tts.l-=1
	end
end

function set_act(a,r,c,act)
	a[r][c].a=act
end

function upd_act_tts(tts)
	for b in all(tts.blks) do
		set_act(ma,b.r,b.c,false)
	end
	
	read_ctrls(tts)

	if timer>0 then
		timer-=1
	else
		if tts.b+1<=#ma then
			for b in all(tts.blks) do
				b.r+=1
			end
			tts.b+=1
			timer=15
		else
			call_nxt=true
		end
	end
	
	for b in all(tts.blks) do
		set_act(ma,b.r,b.c,true)
	end
end

function upd_nxt_tts(tts)	
	for b in all(tts.blks) do
		b.c-=3
		set_act(na,b.r,b.c,true)
		b.c+=3
	end
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
	rect(79,6,121,47,ui.col)
	
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

function draw_blk(a,r,c,col)
	local x=a[r][c].x
	local y=a[r][c].y
	
	spr(col,x,y)
end

function draw_tts(a,tts)
	for i=1,#a do
		for j=1,#a[i] do
			if a[i][j].a then
				draw_blk(a,i,j,tts.col)
			end
		end
	end
end
-->8
--init

--init main area
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

--init next tetris area
function init_na()
	local na={}
	local ox=86 --offset x
	local oy=13 --offset y
	local bs=7 --block side

	for r=0,3 do
		na[r+1]={}
		for c=0,3 do
			na[r+1][c+1]={
				x=c*bs+ox,
				y=r*bs+oy,
				a=false
			}
		end
	end
	
	return na
end


-->8
--tetris
function init_types()
	return {
		--t
		{
			l=4,r=6,t=3,b=4,col=1,
			blks={
				{r=4,c=4},
				{r=4,c=5},
				{r=4,c=6},
				{r=3,c=5}
			}
		},
		--s
		{
			l=4,r=6,t=3,b=4,col=2,
			blks={
				{r=4,c=4},
				{r=4,c=5},
				{r=3,c=5},
				{r=3,c=6}
			}
		},
		--i
		{
			l=5,r=5,t=1,b=4,col=3,
			blks={
				{r=4,c=5},
				{r=3,c=5},
				{r=2,c=5},
				{r=1,c=5}
			}
		},
		--z
		{
			l=4,r=6,t=3,b=4,col=4,
			blks={
				{r=3,c=4},
				{r=3,c=5},
				{r=4,c=5},
				{r=4,c=6}
			}
		},
		--o
		{
			l=5,r=6,t=3,b=4,col=5,
			blks={
				{r=4,c=5},
				{r=4,c=6},
				{r=3,c=5},
				{r=3,c=6}
			}
		},
		--l
		{
			l=5,r=6,t=2,b=4,col=6,
			blks={
				{r=2,c=5},
				{r=3,c=5},
				{r=4,c=5},
				{r=4,c=6}
			}
		},
		--j
		{
			l=5,r=6,t=2,b=4,col=7,
			blks={
				{r=2,c=6},
				{r=3,c=6},
				{r=4,c=6},
				{r=4,c=5}
			}
		}
	}
end

function new_tts()
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
