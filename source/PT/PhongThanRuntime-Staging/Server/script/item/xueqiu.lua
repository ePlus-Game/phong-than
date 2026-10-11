function main(sel)
    if (HaveIBBuff(408) > 0) or (HaveIBBuff(409) > 0) then
        Talk(1, "no", "Bπn Æ∑ chπm ph∂i Tuy’t C«u, tπm thÍi kh´ng th” b· n„!")
    else
        AddIBBuff(408)

        DelNormalItem(6, 1, 331, 0)
        TopMessage("Bπn Æ∑ chπm ph∂i <c=g>Tuy’t C«u<c>! ChÛc vui vŒ!")
        Msg2Player("Bπn Æ∑ chπm ph∂i Tuy’t C«u! H∑y ki™n nh…n! Bπn sœ nhÀn Æ≠Óc Æi“u b t ngÍ!")
    end ;
end

function no()
    CloseDialog()
end;
