Task_PrepareMaterial = 1049;
function main()
    if (GetTask(Task_PrepareMaterial) == 9) then
        local nNum = HaveEventItemCount(199)

        if (GetNpcName(DialogNpcIdx) == (GetName() .. "_Qu’")) then

            DelNpc(DialogNpcIdx)
            if (nNum >= 2) then
                TopMessage(13244)
                Msg2Player("Bπn Æ∑ thu thÀp ÆÒ Hπt qu’.")
            else
                AddEventItem(199)
                TopMessage(13245)
                Msg2Player("Bπn nhÀn Æ≠Óc 1 Hπt qu’.")
            end

        end

    else
        TopMessage(13246)
    end

end
