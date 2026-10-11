--description: “©µÍ-“©¢ª∫ÿ €…Ã
--author: yichuan
--date: 2004/6/10

function main(sel)
	if(GetTask(304)==14)then
			Talk(1,"no","T◊nh h◊nh Î Æ©y Æπi kh∏i nh≠ th’, mau quay v“ thao tr≠Íng b∏o cho v‚ s≠ Æi.")
			SetTask(304,100)
			TaskNote(31,0)
	elseif(GetTask(314)==14)then
			Talk(1,"no","Cµn Kh´n lu©n r t chu»n, hi÷n r t phÊ bi’n Î Tri“u Ca. Mau v“ b∏o tin cho Hoµng Thi™n H„a.")
			SetTask(314,100)
	else
			MsgBox(10322,"yes","no")
	end;
end;

function yes()
		CloseDialog()
		Sale(15);
end;

function no()
		CloseDialog()
end;
