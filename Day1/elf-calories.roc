app "elf-calories"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.1.1/zAoiC9xtQPHywYk350_b7ust04BmWLW00sjb9ZPtSQk.tar.br" }
    imports [
        pf.Process,
        pf.Stdout,
        pf.Stderr,
        pf.Task.{ Task },
        pf.File,
        pf.Path,
    ]
    provides [main] to pf

# Advent of Code 2022: with some pretty rough Roc code!

updateScore = \score ->
    newHighest = List.append score.highest score.currentElfCals |> List.sortDesc |> List.dropLast
    { score & highest: newHighest }


main : Task {} []
main =
    inputPath = Path.fromStr "input.txt"
    task =
        contents <- File.readUtf8 inputPath |> Task.await
        lines = Str.split contents "\n"
        maxCalories = List.walk lines { highest: [0, 0, 0], currentElfCals: 0 } \score, line ->
            if line == "" then
                updatedScore = updateScore score
                { updatedScore & currentElfCals: 0 }
            else
                when Str.toNat line is
                    Ok cals -> { score & currentElfCals: score.currentElfCals + cals }
                    Err _ -> score

        Num.toStr (List.sum maxCalories.highest) |> Stdout.line

    Task.attempt task \result ->
        when result is
            Err err ->
                {} <- Stderr.line "Messed up with the file." |> Task.await
                Process.exit 1
            _ -> Process.exit 0

