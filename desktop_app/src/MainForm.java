import javax.swing.*;

public class MainForm extends JFrame {
    private JPanel rootPanel;
    private JButton currencyUpdateButton;
    private JRadioButton getMoneyRadioButton;
    private JRadioButton putMoneyRadioButton;
    private JRadioButton sendMoneyRadioButton;
    private JTextField depositTextField;
    private JTextField pinTextField;
    private JTextField sumTextField;
    private JTextField depositToTextField;
    private JButton performButton;
    private JTextArea logTextArea;
    private JLabel currencyLabel;
    private JRadioButton getBalanceRadioButton;
    private JLabel depositLabel;
    private JLabel pinLabel;
    private JLabel sumLabel;
    private JLabel depositToLabel;

    public MainForm() {
        setContentPane(rootPanel);
        setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
    }
}
