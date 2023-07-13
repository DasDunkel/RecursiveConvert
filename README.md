# RecursiveConvert
Just a lil script to recrsively convert all video files in a folder

Make sure to change the `workdir` variable to a suitable location, default is `$PWD/convert`

Directory structure will be maintained inside the workdir

All prompts default to No

#### Example `./convert.sh ./Test/`
<details>
<summary>Example input structure</summary>

```
Test
├── 1FolderWithoutSpaces
│   ├── 4K 10-bit HDR.mp4
│   ├── Broken Mp4 File.mp4
│   ├── Broken Mp4 File With " Double Quotes".mp4
│   ├── Broken Mp4 File With ' single Quote's.mp4
│   ├── Mkv File.mkv
│   ├── MkvFile.mkv
│   ├── Mov File.mov
│   ├── MovFile.mov
│   ├── Mp4 File.mp4
│   ├── Mp4File.mp4
│   ├── Mp4 With " Double Quotes".mp4
│   └── Mp4 With ' Single Quote's.mp4
├── 2 Folder With Spaces
│   ├── 4K 10-bit HDR.mp4
│   ├── Broken Mp4 File.mp4
│   ├── Broken Mp4 File With " Double Quotes".mp4
│   ├── Broken Mp4 File With ' single Quote's.mp4
│   ├── Mkv File.mkv
│   ├── MkvFile.mkv
│   ├── Mov File.mov
│   ├── MovFile.mov
│   ├── Mp4 File.mp4
│   ├── Mp4File.mp4
│   ├── Mp4 With " Double Quotes".mp4
│   └── Mp4 With ' Single Quote's.mp4
├── 3 Folder With ' Single Quote's
│   ├── 4K 10-bit HDR.mp4
│   ├── Broken Mp4 File.mp4
│   ├── Broken Mp4 File With " Double Quotes".mp4
│   ├── Broken Mp4 File With ' single Quote's.mp4
│   ├── Mkv File.mkv
│   ├── MkvFile.mkv
│   ├── Mov File.mov
│   ├── MovFile.mov
│   ├── Mp4 File.mp4
│   ├── Mp4File.mp4
│   ├── Mp4 With " Double Quotes".mp4
│   └── Mp4 With ' Single Quote's.mp4
├── 4 Folder With " Double Quotes"
│   ├── 4K 10-bit HDR.mp4
│   ├── Broken Mp4 File.mp4
│   ├── Broken Mp4 File With " Double Quotes".mp4
│   ├── Broken Mp4 File With ' single Quote's.mp4
│   ├── Mkv File.mkv
│   ├── MkvFile.mkv
│   ├── Mov File.mov
│   ├── MovFile.mov
│   ├── Mp4 File.mp4
│   ├── Mp4File.mp4
│   ├── Mp4 With " Double Quotes".mp4
│   └── Mp4 With ' Single Quote's.mp4
└── 5 Nested Copy
    ├── 1FolderWithoutSpaces
    │   ├── Broken Mp4 File.mp4
    │   ├── Broken Mp4 File With " Double Quotes".mp4
    │   ├── Broken Mp4 File With ' single Quote's.mp4
    │   ├── Mkv File.mkv
    │   ├── MkvFile.mkv
    │   ├── Mov File.mov
    │   ├── MovFile.mov
    │   ├── Mp4 File.mp4
    │   ├── Mp4File.mp4
    │   ├── Mp4 With " Double Quotes".mp4
    │   └── Mp4 With ' Single Quote's.mp4
    ├── 2 Folder With Spaces
    │   ├── Broken Mp4 File.mp4
    │   ├── Broken Mp4 File With " Double Quotes".mp4
    │   ├── Broken Mp4 File With ' single Quote's.mp4
    │   ├── Mkv File.mkv
    │   ├── MkvFile.mkv
    │   ├── Mov File.mov
    │   ├── MovFile.mov
    │   ├── Mp4 File.mp4
    │   ├── Mp4File.mp4
    │   ├── Mp4 With " Double Quotes".mp4
    │   └── Mp4 With ' Single Quote's.mp4
    ├── 3 Folder With ' Single Quote's
    │   ├── Broken Mp4 File.mp4
    │   ├── Broken Mp4 File With " Double Quotes".mp4
    │   ├── Broken Mp4 File With ' single Quote's.mp4
    │   ├── Mkv File.mkv
    │   ├── MkvFile.mkv
    │   ├── Mov File.mov
    │   ├── MovFile.mov
    │   ├── Mp4 File.mp4
    │   ├── Mp4File.mp4
    │   ├── Mp4 With " Double Quotes".mp4
    │   └── Mp4 With ' Single Quote's.mp4
    └── 4 Folder With " Double Quotes"
        ├── Broken Mp4 File.mp4
        ├── Broken Mp4 File With " Double Quotes".mp4
        ├── Broken Mp4 File With ' single Quote's.mp4
        ├── Mkv File.mkv
        ├── MkvFile.mkv
        ├── Mov File.mov
        ├── MovFile.mov
        ├── Mp4 File.mp4
        ├── Mp4File.mp4
        ├── Mp4 With " Double Quotes".mp4
        └── Mp4 With ' Single Quote's.mp4
```

</details>

<details>
<summary>Resulting structure</summary>
  
```
convert
└── Test
    ├── 1FolderWithoutSpaces
    │   ├── 4K 10-bit HDR.mp4.error
    │   ├── Broken Mp4 File.mp4.error
    │   ├── Broken Mp4 File With " Double Quotes".mp4.error
    │   ├── Broken Mp4 File With ' single Quote's.mp4.error
    │   ├── Mkv File.mp4
    │   ├── MkvFile.mp4
    │   ├── Mov File.mp4
    │   ├── MovFile.mp4
    │   ├── Mp4 File.mp4
    │   ├── Mp4File.mp4
    │   ├── Mp4 With " Double Quotes".mp4
    │   └── Mp4 With ' Single Quote's.mp4
    ├── 2 Folder With Spaces
    │   ├── 4K 10-bit HDR.mp4.error
    │   ├── Broken Mp4 File.mp4.error
    │   ├── Broken Mp4 File With " Double Quotes".mp4.error
    │   ├── Broken Mp4 File With ' single Quote's.mp4.error
    │   ├── Mkv File.mp4
    │   ├── MkvFile.mp4
    │   ├── Mov File.mp4
    │   ├── MovFile.mp4
    │   ├── Mp4 File.mp4
    │   ├── Mp4File.mp4
    │   ├── Mp4 With " Double Quotes".mp4
    │   └── Mp4 With ' Single Quote's.mp4
    ├── 3 Folder With ' Single Quote's
    │   ├── 4K 10-bit HDR.mp4.error
    │   ├── Broken Mp4 File.mp4.error
    │   ├── Broken Mp4 File With " Double Quotes".mp4.error
    │   ├── Broken Mp4 File With ' single Quote's.mp4.error
    │   ├── Mkv File.mp4
    │   ├── MkvFile.mp4
    │   ├── Mov File.mp4
    │   ├── MovFile.mp4
    │   ├── Mp4 File.mp4
    │   ├── Mp4File.mp4
    │   ├── Mp4 With " Double Quotes".mp4
    │   └── Mp4 With ' Single Quote's.mp4
    ├── 4 Folder With " Double Quotes"
    │   ├── 4K 10-bit HDR.mp4.error
    │   ├── Broken Mp4 File.mp4.error
    │   ├── Broken Mp4 File With " Double Quotes".mp4.error
    │   ├── Broken Mp4 File With ' single Quote's.mp4.error
    │   ├── Mkv File.mp4
    │   ├── MkvFile.mp4
    │   ├── Mov File.mp4
    │   ├── MovFile.mp4
    │   ├── Mp4 File.mp4
    │   ├── Mp4File.mp4
    │   ├── Mp4 With " Double Quotes".mp4
    │   └── Mp4 With ' Single Quote's.mp4
    └── 5 Nested Copy
        ├── 1FolderWithoutSpaces
        │   ├── Broken Mp4 File.mp4.error
        │   ├── Broken Mp4 File With " Double Quotes".mp4.error
        │   ├── Broken Mp4 File With ' single Quote's.mp4.error
        │   ├── Mkv File.mkv.error
        │   ├── Mkv File.mp4
        │   ├── MkvFile.mp4
        │   ├── Mov File.mp4
        │   ├── MovFile.mp4
        │   ├── Mp4 File.mp4
        │   ├── Mp4File.mp4
        │   ├── Mp4 With " Double Quotes".mp4
        │   └── Mp4 With ' Single Quote's.mp4
        ├── 2 Folder With Spaces
        │   ├── Broken Mp4 File.mp4.error
        │   ├── Broken Mp4 File With " Double Quotes".mp4.error
        │   ├── Broken Mp4 File With ' single Quote's.mp4.error
        │   ├── Mkv File.mkv.error
        │   ├── Mkv File.mp4
        │   ├── MkvFile.mp4
        │   ├── Mov File.mp4
        │   ├── MovFile.mp4
        │   ├── Mp4 File.mp4
        │   ├── Mp4File.mp4
        │   ├── Mp4 With " Double Quotes".mp4
        │   └── Mp4 With ' Single Quote's.mp4
        ├── 3 Folder With ' Single Quote's
        │   ├── Broken Mp4 File.mp4.error
        │   ├── Broken Mp4 File With " Double Quotes".mp4.error
        │   ├── Broken Mp4 File With ' single Quote's.mp4.error
        │   ├── Mkv File.mkv.error
        │   ├── Mkv File.mp4
        │   ├── MkvFile.mp4
        │   ├── Mov File.mp4
        │   ├── MovFile.mp4
        │   ├── Mp4 File.mp4
        │   ├── Mp4File.mp4
        │   ├── Mp4 With " Double Quotes".mp4
        │   └── Mp4 With ' Single Quote's.mp4
        └── 4 Folder With " Double Quotes"
            ├── Broken Mp4 File.mp4.error
            ├── Broken Mp4 File With " Double Quotes".mp4.error
            ├── Broken Mp4 File With ' single Quote's.mp4.error
            ├── Mkv File.mkv.error
            ├── Mkv File.mp4
            ├── MkvFile.mp4
            ├── Mov File.mp4
            ├── MovFile.mp4
            ├── Mp4 File.mp4
            ├── Mp4File.mp4
            ├── Mp4 With " Double Quotes".mp4
            └── Mp4 With ' Single Quote's.mp4
```

</details>

<br/>

If you get errors or warnings from ffmpeg they will be output to the files output path prefixed with `.error` as shown above, files from a previous run will be moved to `.error.old`
The script offers an automatic cleanup at the end to remove error logs

### Todo
- Option to consolidate all errors into a single file on cleanup prompt
- Do the funky

https://github.com/DasDunkel/RecursiveConvert/assets/47669082/13319148-1aa2-4350-966d-966c5fe144f2
