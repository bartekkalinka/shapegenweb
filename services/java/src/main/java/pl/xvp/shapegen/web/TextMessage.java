package pl.xvp.shapegen.web;

public final class TextMessage {

	public String getText() {
		return text;
	}
	
	public static TextMessage message(String text) {
		return new TextMessage(text);
	}
	
	// internal
	
	private String text;
	
	private TextMessage(String text) {
		this.text = text;
	}
	
}
