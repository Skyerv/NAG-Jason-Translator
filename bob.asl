naotenho(GuardaChuva).
esta(Chovendo).

!nao(PegarChuva).
!comprar(GuardaChuva).

@plano1
+!comprar(GuardaChuva) : esta(Chovendo) & naotenho(GuardaChuva) <-
   sair;
   procurar(Loja);
   comprar(GuardaChuva).

@plano2
+!nao(PegarChuva) : ~esta(Chovendo) <-
   sair;
   jogar(Bola);
   comer.

@plano3
+!nao(PegarChuva) : esta(Chovendo) & naotenho(GuardaChuva) <-
   ficar(EmCasa);
   estudar.

