import javax.swing.*;

public class MainForm extends JFrame {
    private JPanel rootPanel;
    private JButton currencyUpdateButton;
    private JRadioButton getBalanceRadioButton;
    private JRadioButton getMoneyRadioButton;
    private JRadioButton putMoneyRadioButton;
    private JRadioButton sendMoneyRadioButton;
    private JLabel currencyLabel;
    private JLabel depositLabel;
    private JLabel pinLabel;
    private JLabel sumLabel;
    private JLabel depositToLabel;
    private JTextField depositTextField;
    private JPasswordField pinPasswordField;
    private JTextField sumTextField;
    private JTextField depositToTextField;
    private JButton performButton;
    private JTextArea logTextArea;

    public MainForm() {
        setContentPane(rootPanel);
        setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);

        ButtonGroup radioButtons = new ButtonGroup();

        radioButtons.add(getBalanceRadioButton);
        radioButtons.add(getMoneyRadioButton);
        radioButtons.add(putMoneyRadioButton);
        radioButtons.add(sendMoneyRadioButton);

        getBalanceRadioButton.addActionListener(e -> {
            setSumEnabled(false);
            setDepositToEnabled(false);
        });

        getMoneyRadioButton.addActionListener(e -> {
            setSumEnabled(true);
            setDepositToEnabled(false);
        });

        putMoneyRadioButton.addActionListener(e -> {
            setSumEnabled(true);
            setDepositToEnabled(false);
        });

        sendMoneyRadioButton.addActionListener(e -> {
            setSumEnabled(true);
            setDepositToEnabled(true);
        });

        currencyUpdateButton.addActionListener(e -> {
            int eur = 70;
            int usd = 60;
            currencyLabel.setText("EUR: " + eur + ", USD: " + usd);
        });

        performButton.addActionListener(e -> {
            int deposit = Integer.valueOf(depositTextField.getText());
            int pin = Integer.valueOf(new String(pinPasswordField.getPassword()));
            if (getBalanceRadioButton.isSelected()) {
                logTextArea.append("balance " + deposit + " " + pin + "\n");
            } else {
                double sum = Double.valueOf(sumTextField.getText());
                if (getMoneyRadioButton.isSelected()) {
                    logTextArea.append("get " + deposit + " " + pin + " " + sum + "\n");
                } else if (putMoneyRadioButton.isSelected()) {
                    logTextArea.append("put " + deposit + " " + pin + " " + sum + "\n");
                } else {
                    int depositTo = Integer.valueOf(depositToTextField.getText());
                    logTextArea.append("send " + deposit + " " + pin + " " + sum + " " + depositTo + "\n");
                }
            }
        });
    }

    private void setSumEnabled(boolean value) {
        sumLabel.setEnabled(value);
        sumTextField.setEditable(value);
    }

    private void setDepositToEnabled(boolean value) {
        depositToLabel.setEnabled(value);
        depositToTextField.setEditable(value);
    }
}
