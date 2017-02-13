public class Main {
    public static void main(String[] args) {
        String serverNodeName = args[0];
        String selfNodeName = args[1];

        Communicator communicator = new Communicator(serverNodeName, selfNodeName);
        communicator.connectToServer();

        int[] currency = communicator.getCurrency();
        System.out.println("eur: " + currency[0]);
        System.out.println("usd: " + currency[1]);
    }
}
