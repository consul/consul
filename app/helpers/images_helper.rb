module ImagesHelper
  def image_absolute_url(investment, version)
    return "" unless investment.image
    
    if Paperclip::Attachment.default_options[:storage] == :filesystem
      URI(request.url) + investment.image.attachment.url(version)
    else
      investment.image_url(version)
    end
  end

  def image_attachment_file_name(image)
    image.attachment_file_name
  end

  def image_errors_on_attachment(image)
    image.errors[:attachment].join(", ") if image.errors.key?(:attachment)
  end

  def image_class(image)
    image.persisted? ? "persisted-image" : "cached-image"
  end

  def render_destroy_image_link(builder, image)
    if !image.persisted? && image.cached_attachment.present?
      link_to t("images.form.delete_button"),
              direct_upload_destroy_path(
                "direct_upload[resource_type]": image.imageable_type,
                "direct_upload[resource_id]": image.imageable_id,
                "direct_upload[resource_relation]": "image",
                "direct_upload[cached_attachment]": image.cached_attachment
              ),
              method: :delete,
              remote: true,
              class: "delete remove-cached-attachment"
    else
      link_to_remove_association t("images.form.delete_button"), builder, class: "delete remove-image"
    end
  end

  def render_image_attachment(builder, imageable, image)
    klass = image.persisted? || image.cached_attachment.present? ? " hide" : ""
    builder.file_field :attachment,
                       label_options: { class: "button hollow #{klass}" },
                       accept: imageable_accepted_content_types_extensions,
                       class: "js-image-attachment",
                       data: {
                         url: image_direct_upload_path(imageable),
                         nested_image: true
                       }
  end

  def render_image(image, version, show_caption = true)
    version = image.persisted? ? version : :original
    render "images/image", image: image,
                           version: version,
                           show_caption: show_caption
  end

  def image_direct_upload_path(imageable)
    direct_uploads_path("direct_upload[resource_type]": imageable.class.name,
                        "direct_upload[resource_id]": imageable.id,
                        "direct_upload[resource_relation]": "image")
  end
end
