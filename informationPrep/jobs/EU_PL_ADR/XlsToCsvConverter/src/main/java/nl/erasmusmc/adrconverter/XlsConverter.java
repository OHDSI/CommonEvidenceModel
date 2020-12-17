package nl.erasmusmc.adrconverter;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVPrinter;
import org.apache.poi.ss.usermodel.*;

import java.io.*;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Iterator;

import static org.apache.poi.ss.usermodel.Row.MissingCellPolicy.RETURN_NULL_AND_BLANK;

public class XlsConverter {


    public static void main(String[] args) {
        final DateFormat formatter = new SimpleDateFormat("dd/MM/yyyy");

        String path = args[0];

        System.out.println("Loading file: " + path);

        try (Workbook workbook = WorkbookFactory.create(new File(path));
             OutputStream out = new FileOutputStream(path.substring(0, path.length() - 4) + ".csv");
             CSVPrinter csvPrinter = new CSVPrinter(new OutputStreamWriter(out),
                     CSVFormat.DEFAULT.withRecordSeparator(System.getProperty("line.separator")))) {

            System.out.println("Processing " + workbook.getNumberOfSheets() + " sheets");

            Iterator<Sheet> sheetIterator = workbook.sheetIterator();

            boolean isFirstSheet = true;
            while (sheetIterator.hasNext()) {
                Sheet sheet = sheetIterator.next();
                System.out.println("Loading sheet: " + sheet.getSheetName());
                Iterator<Row> rowIterator = sheet.rowIterator();
                boolean isData = false;
                while (rowIterator.hasNext()) {
                    Row row = rowIterator.next();
                    // Skip the first x number of rows with non relevant info
                    if (getStringCellValue(row.getCell(0), formatter).equalsIgnoreCase("PRODUCT")) {
                        isData = true;
                    }
                    if (!isData) {
                        System.out.println("File info: " + getStringCellValue(row.getCell(0), formatter));
                        continue;
                    }
                    if (!isFirstSheet && row.getCell(0).getStringCellValue().equalsIgnoreCase("PRODUCT")) {
                        System.out.println("Skipping headers in consecutive sheet");
                        continue;
                    }
                    logProcess(row);
                    // the second sheet has an extra column
                    int columns = isFirstSheet ? 19 : 20;
                    for (int cn = 0; cn < columns; cn++) {
                        printColumn(isFirstSheet, cn, row, formatter, csvPrinter);
                    }
                    csvPrinter.println(); // Newline after each row
                }
                isFirstSheet = false;
            }
            csvPrinter.flush(); // Flush and close CSVPrinter
        } catch (Exception e) {
            e.printStackTrace();
        }
        System.out.println("Done!");
    }

    private static void printColumn(boolean isFirstSheet, int cn, Row row, DateFormat formatter, CSVPrinter csvPrinter) throws ParseException, IOException {
        String value = "";
        if (!isFirstSheet && cn == 1) {
            return;
        }
        Cell cell = row.getCell(cn, RETURN_NULL_AND_BLANK);
        if (cell != null) {
            if ((isFirstSheet && cn == 2) || (!isFirstSheet && cn == 3)) {
                value = getSmPCDate(cell, formatter);
            } else {
                value = getStringCellValue(cell, formatter);
            }
        }
        if (value.equalsIgnoreCase("N/A")) {
            value = "";
        }
        csvPrinter.print(value);
    }


    private static String getSmPCDate(Cell cell, DateFormat formatter) throws ParseException {
        String date = "";
        if (cell.getCellType() == CellType.NUMERIC) {
            date = formatter.format(cell.getDateCellValue());
        } else {
            String trimmedString = cell.getStringCellValue().replace("(opinion)", "").trim();
            // different date formats are used in the file, here they are unified
            if (trimmedString.length() == 10) {
                date = trimmedString;
            } else if (trimmedString.length() == 8) {
                SimpleDateFormat simpleDateFormat = new SimpleDateFormat("dd/MM/yy");
                simpleDateFormat.set2DigitYearStart(formatter.parse("01/01/1999"));
                date = formatter.format(simpleDateFormat.parse(trimmedString));
            } else {
                // most likely the header
                return trimmedString;
            }
        }
        return date;
    }

    public static String getStringCellValue(Cell cell, DateFormat formatter) {
        String result = "";
        if (cell != null) {
            switch (cell.getCellType()) {
                case STRING:
                    result = cell.getStringCellValue();
                    break;
                case NUMERIC:
                    if (DateUtil.isCellDateFormatted(cell)) {
                        result = formatter.format(cell.getDateCellValue());
                    } else {
                        if (cell.getNumericCellValue() == (long) cell.getNumericCellValue())
                            result = String.format("%s", (long) cell.getNumericCellValue());
                        else
                            result = String.format("%s", cell.getNumericCellValue());
                    }
                    break;
                case BOOLEAN:
                    result = Boolean.toString(cell.getBooleanCellValue());
                    break;
                case FORMULA:
                    result = cell.getCellFormula();
                    break;
                default:
            }
        }
        return result;
    }

    private static void logProcess(Row row) {
        if (row.getRowNum() % 2500 == 0) {
            System.out.println("Processed " + row.getRowNum() + " rows");
        }
    }

}
