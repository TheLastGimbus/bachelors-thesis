
# Wyznaczanie przepływu z pomiaru próżniomierza

Nasz mass flow meter alicata nie pracował zbyt dobrze w tak drobnych zakresach których używamy (dosłownie okolice 0.1~4 sccm / 0.002~0.07 mg/s). Poza tym, posiadanie go wpiętego cały czas w układ było upierdliwe

Biorąc pod uwage, że po pewnym czasie odpompowywania i stabilizacji, nasza pompa próżniowa cały czas pompuje tyle samo, założyliśmy że możemy szacować wpływający gaz po ciśnieniu jakie ustabilizuje się w komorze

Zebrałem troche pomiarów tej zależności i oto co wyszło

# Pomiar z alicata

Przestawiliśmy alicata z sccm na mg/s bo w ten sposób mógł nam dawać większą rozdzielczość

Czytaliśmy go ofc za pomocą quadrupola

# Pomiar z próżniomierza

Próżniomierz wypluwa nam sygnał 0-10V, i według wzoru producenta:

$$ P[Pa] = 10^{(1.667* U[V] - 9.333)} $$
Mierzyłem to mierniczkiem Brymen BM811S

# Eksperyment✨

Polegał na tym, że powoli odkręcałem kręciołka, zostawiałem na jakiejś pozycji i czekałem aż ciśnienie sie ustabilizuje. I tak parenaście razy na różne odkręcenia

# Obróbka sweepa

Z eksperymentu wyszedł taki oto sweep


![[cisnienie-a-alicat.png|340]]

Poprosiłem czata żeby mi zrobił skrypt który przemieli to i zostawi same punkty pod koniec stabilizacji - "punkty tuż przed tym, jak zacząłem kręcić dalej"

Zrobił `filter.py` który wypluwa `steady_points.csv`, i jeszcze do tego z `plot.py` zrobił mi rysunek ładny:

![[same-punkty-plot.png]]

# Zfittowanie wzoru w Originie

Wrzuciłem te punkty w Origina i poeksperymentowałem z różnymi fittami - całkiem spoko sprawdził się wielomian-3

![[fit-lin-lin.png|215]] ![[fit-log-lin.png|215]] ![[fit-log-log.png|215]] 

Jego output:
```
y = Intercept + B1*x^1 + B2*x^2 + B3*x^3

Intercept	0.00217 ± 0.00149
B1	0.29089 ± 0.15695
B2	12.65459 ± 4.31392
B3	-81.7547 ± 32.82514
```

Czyli, po europejsku:

$$ y = -81.7547*x^3 + 12.65459*x^2 + 0.29089*x + 0.00217 $$

a z kolei x to ciśnienie, czyli dla przypomnienia:

$$ x[Pa] =  10^{(1.667 * U[V] - 9.333)} $$

czyli pełny wzór y = f(x) gdzie:
y - mass flow mg/s
x - voltage

To:
$$ y = -81.7547*(10^{(1.667*x - 9.333)})^3 + 12.65459*(10^{(1.667*x - 9.333)})^2 + 0.29089*(10^{(1.667*x - 9.333)}) + 0.00217 $$

Ale obviously w jakimś kodzie można najpierw policzyć ciśnienie X do zmiennej a potem ją wstawiać do wielomianu 👍
# 🎉🎉🎉🎉



